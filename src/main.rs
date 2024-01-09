use std::fs;
use std::path::Path;
use std::thread;
use std::time::Duration;
use std::sync::mpsc::channel;
use std::process::Command;
use std::error::Error;
use notify::{RecommendedWatcher, RecursiveMode, Watcher, Config};
use glob::glob;

use std::os::unix::fs::PermissionsExt;

//  check if the current user has read permissions for a given path
fn has_read_permission<P: AsRef<Path>>(path: P) -> Result<bool, Box<dyn Error>> {
    let metadata = fs::metadata(path.as_ref())?;
    let permissions = metadata.permissions();
    let mode = permissions.mode();
    Ok(mode & 0o444 != 0)
}



fn main() -> Result<(), Box<dyn Error>> {
    println!("Starting the battery monitor...");

    let bat_base_paths = glob("/sys/class/power_supply/BAT*")?.filter_map(Result::ok);

    let mut bat_status_path = String::new();
    let mut bat_capacity_path = String::new();

    for path in bat_base_paths {
        println!("Found battery path: {:?}", path.display());
        bat_status_path = format!("{}/status", path.display());
        bat_capacity_path = format!("{}/capacity", path.display());
        // break after finding the first match.
        // FIXME:  this is assuming there's only one battery, account for multiple?
        break;
    }

    if bat_status_path.is_empty() || bat_capacity_path.is_empty() {
        return Err("Battery path not found".into());
    }

    // check if we have read permissions for the battery status and capacity paths
    // TODO: I'm pretty sure there's a better and faster way to do this
    if !has_read_permission(&bat_status_path)? {
        println!("No read permission for the battery status path");
        return Err("Permission denied".into());
    }

    if !has_read_permission(&bat_capacity_path)? {
        println!("No read permission for the battery capacity path");
        return Err("Permission denied".into());
    }

    println!("Battery status path: {}", bat_status_path);
    println!("Battery capacity path: {}", bat_capacity_path);

    let ac_profile = "performance";
    let bat_profile = "balanced";

    if let Ok(wait_time_str) = std::env::var("STARTUP_WAIT") {
        println!("STARTUP_WAIT is set, waiting for {} seconds", wait_time_str);
        if let Ok(wait_time) = wait_time_str.parse::<u64>() {
            thread::sleep(Duration::from_secs(wait_time));
        } else {
        println!("Invalid STARTUP_WAIT value: {}", wait_time_str);
        }
    }

    let mut prev_profile = String::new();

    let (tx, rx) = channel();
    let mut watcher = RecommendedWatcher::new(tx, Config::default())?;

    println!("Watching battery status and capacity paths for changes...");
    watcher.watch(Path::new(&bat_status_path), RecursiveMode::NonRecursive)?;
    watcher.watch(Path::new(&bat_capacity_path), RecursiveMode::NonRecursive)?;

    loop {
        match rx.recv() {
            Ok(_) => {
                println!("Change detected in battery status or capacity.");
                let current_status = fs::read_to_string(&bat_status_path)?.trim().to_string();
                println!("Current battery status: {}", current_status);

                let profile = if current_status == "Discharging" {
                    bat_profile
                } else {
                    ac_profile
                };

                if prev_profile != profile {
                    println!("Setting power profile to {}", profile);
                    let output = Command::new("powerprofilesctl")
                        .arg("set")
                        .arg(profile)
                        .output()?;

                    if !output.status.success() {
                        let stderr = String::from_utf8_lossy(&output.stderr);
                        println!("Failed to set power profile: {}", stderr);
                    }
                }
                prev_profile = profile.to_string();
            },
            Err(e) => println!("Watch error: {:?}", e),
        }
    }
}

