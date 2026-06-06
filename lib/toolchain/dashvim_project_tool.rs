use std::env;
use std::ffi::OsString;
use std::fs;
use std::os::unix::fs::PermissionsExt;
use std::os::unix::process::CommandExt;
use std::path::{Path, PathBuf};
use std::process::Command;

mod tool_config;

#[derive(Debug)]
pub struct Tool {
    pub name: &'static str,
    pub commands: &'static [&'static str],
    pub fallback: &'static str,
}

fn main() {
    let Some(tool) = current_tool() else {
        eprintln!("dashvim project tool resolver: could not determine requested tool");
        std::process::exit(127);
    };

    let command = resolve(tool).unwrap_or_else(|| PathBuf::from(tool.fallback));
    let error = Command::new(command).args(env::args_os().skip(1)).exec();
    eprintln!(
        "dashvim project tool resolver: failed to exec {}: {error}",
        tool.name
    );
    std::process::exit(127);
}

fn current_tool() -> Option<&'static Tool> {
    let requested = env::var_os("DASHVIM_PROJECT_TOOL_NAME")
        .or_else(|| env::args_os().next().and_then(basename))
        .and_then(strip_prefix)?;

    tool_config::TOOLS
        .iter()
        .find(|tool| tool.name == requested)
}

fn basename(path: OsString) -> Option<OsString> {
    Path::new(&path).file_name().map(OsString::from)
}

fn strip_prefix(name: OsString) -> Option<String> {
    let name = name.into_string().ok()?;
    Some(
        name.strip_prefix("dashvim-project-tool-")
            .unwrap_or(&name)
            .to_owned(),
    )
}

fn resolve(tool: &Tool) -> Option<PathBuf> {
    let fallback = PathBuf::from(tool.fallback);
    let fallback_real = realpath(&fallback);

    for dir in path_entries() {
        for command in tool.commands {
            let candidate = dir.join(command);
            if is_executable(&candidate) && realpath(&candidate) != fallback_real {
                return Some(candidate);
            }
        }
    }

    None
}

fn path_entries() -> Vec<PathBuf> {
    env::var_os("PATH")
        .map(|path| {
            env::split_paths(&path)
                .map(|entry| {
                    if entry.as_os_str().is_empty() {
                        PathBuf::from(".")
                    } else {
                        entry
                    }
                })
                .collect()
        })
        .unwrap_or_default()
}

fn is_executable(path: &Path) -> bool {
    fs::metadata(path)
        .map(|metadata| metadata.is_file() && metadata.permissions().mode() & 0o111 != 0)
        .unwrap_or(false)
}

fn realpath(path: &Path) -> PathBuf {
    fs::canonicalize(path).unwrap_or_else(|_| path.to_path_buf())
}
