# /// script
# requires-python = ">=3.10"
# dependencies = []
# ///
"""Dummy ZP module for testing."""

import argparse
import json
import sys
from pathlib import Path


def emit(type_: str, msg: str, name: str = "", **kwargs):
    event = {"type": type_, "msg": msg, "name": name}
    if kwargs:
        event["data"] = kwargs
    print(json.dumps(event), flush=True)


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--input", required=True)
    args = parser.parse_args()

    with open(args.input, encoding="utf-8") as f:
        data = json.load(f)

    output_dir = Path(data["output_dir"])
    result_files = []

    for file_info in data["files"]:
        fp = Path(file_info["file_path"])
        module_cfg = file_info.get("module_config", {})

        emit("detail", f"dummy_module: processing '{fp.name}'",
             name="dummy_module.processing",
             filename=fp.name, config_key=file_info["config_key"])

        if module_cfg.get("fail"):
            emit("error", f"dummy_module: forced failure for '{fp.name}'",
                 name="dummy_module.forced_error")
            sys.exit(1)

        out_path = output_dir / f"{fp.name}.dummy"
        out_path.write_text(f"dummy:{fp.name}")

        emit("detail_ok", f"dummy_module: produced {out_path.name}",
             name="dummy_module.done", filename=out_path.name)

        result_files.append({
            "file_path": str(out_path),
            "config_key": file_info["config_key"],
            "module_entry_type": "out",
            "publishers": {"destination": {}},
        })

    print(json.dumps({"type": "result", "files": result_files}), flush=True)


if __name__ == "__main__":
    main()
