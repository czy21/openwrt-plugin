import argparse
import json
import os
import pathlib
from jinja2 import Template

def flat(a) -> list: return sum(map(flat, a), []) if isinstance(a, list) else [a]

if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('--openwrt-dir', required=True, help="openwrt workspace")
    parser.add_argument('--config', required=True, help='config directory')
    parser.add_argument('--target', required=True, help='target directory')
    args: argparse.Namespace = parser.parse_args()

    config_path = pathlib.Path(args.config)

    global_profiles=config_path.joinpath("profiles.json")
    global_profiles_obj=json.loads(global_profiles.read_text(encoding='utf8'))

    target_path = config_path.joinpath(args.target)
    target_profiles_file = target_path.joinpath('profiles.json')
    if not target_profiles_file.exists():
        print(f"{target_profiles_file} not found")
        exit(0)
    profiles_obj = json.load(open(target_profiles_file, 'r'))
    profiles = profiles_obj['profiles']

    for pk, pv in profiles.items():
        cmd_arr = [
            f"cd {args.openwrt_dir};",
            "make image",
            f"PROFILE={pk}"
        ]
        user_configs = pv.get("user_configs", [])

        packages = pv.get("user_packages", [])
        for i,t in enumerate(packages):
            t_result=Template(t).render(global_profiles_obj["packages"])
            packages[i] = t_result
        
        if packages:
            cmd_arr.append(f"PACKAGES=\"{' '.join(packages)}\"")
            
        if user_configs:
            cmd_arr.append(' '.join(user_configs))
        cmd_arr.append('FILES=files')
        cmd_str = ' '.join(cmd_arr)
        os.system(f"echo \'{cmd_str}\'")
        os.system(cmd_str)
