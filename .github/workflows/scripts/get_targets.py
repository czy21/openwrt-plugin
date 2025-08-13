import json
import pathlib

targets = []
subtargets = []
archs = []

packages_path = pathlib.Path(__file__).joinpath("../../../../packages.json")
if packages_path.exists():
    packages_objs = json.loads(packages_path.read_text())
    archs.extend([p['name'] for p in packages_objs if p['type'] == 'directory'])

config_path = pathlib.Path(__file__).joinpath("../../../../config").resolve()
global_profiles = config_path.joinpath("profiles.json")
for p in config_path.rglob("**/*profiles.json"):
    if p == global_profiles:
        continue
    profile_obj = json.loads(p.read_text())
    profile_target = profile_obj.get("target")

    target = profile_target.split("/")[0]
    subtarget = profile_target.split("/")[1]
    targets.append(target)
    subtargets.append({"target": target, "subtarget": subtarget})

print("targets={0}".format(json.dumps(targets)))
print("targets_subtargets={0}".format(json.dumps(subtargets)))
print("archs={0}".format(json.dumps(archs)))
