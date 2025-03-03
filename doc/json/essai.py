import json

def load_json(file_path):
    with open(file_path, "r", encoding="utf-8") as f:
        return json.load(f)

def get_unit_symbol(unit_type, separated=False):
    if unit_type == "package":
        return "_[" if separated else "["
    elif unit_type == "subprogram":
        return "_(" if separated else "("
    return "?"

def build_hierarchy(unit, prefix=""):
    symbol = get_unit_symbol(unit["unit_type"], separated=False)
    result = f"{prefix}{symbol}{unit['unit']}\n"

    # Body of the unit
    if "unit_body" in unit and "file_path" in unit["unit_body"]:
        body_symbol = get_unit_symbol(unit["unit_type"], separated=True)
        result += f"{prefix}  {body_symbol}{unit['unit']}_body\n"

        # Separate units inside body
        for sub in unit["unit_body"].get("sep_units", []):
            result += build_hierarchy(sub, prefix + "    ")

    # Sub-units
    for sub in unit.get("subs", []):
        result += build_hierarchy(sub, prefix + "  ")

    return result

def build_dependency_links(program_units):
    links = []
    unit_dict = {unit["unit"]: unit for unit in program_units}

    for unit in program_units:
        unit_name = unit["unit"]

        # Check with dependencies in spec
        for dep in unit.get("withed_units", []):
            links.append(f"[{dep}] --> [{unit_name}]")

        # Check with dependencies in body
        if "unit_body" in unit:
            for dep in unit["unit_body"].get("withed_units", []):
                links.append(f"[{dep}] --> [{unit_name}_body]")

    return "\n".join(links)

def generate_ascii_diagram(json_data):
    program_units = json_data["program"]
    hierarchy = "".join(build_hierarchy(unit) for unit in program_units)
    dependencies = build_dependency_links(program_units)

    return f"{hierarchy}\n{dependencies}"

if __name__ == "__main__":
    json_data = load_json("structure.json")  # Remplace avec ton fichier
    ascii_diagram = generate_ascii_diagram(json_data)
    print(ascii_diagram)
