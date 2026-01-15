# VERIFY.EXE: Prop Management & Asset Workflow

## 1. The "Graybox to Final" Vision
This project utilizes a **Modular Spawner System**. We use simple Godot primitive meshes (cubes, cylinders) to define positions and logic. This allows us to build the entire SOC infrastructure before the final 3D art is ready.

## 2. Technical Implementation: `PropSpawner.gd`
The `PropSpawner` node in the `SOC_Office` scene handles the automatic population of the 24+ analyst workstations.

### Key Logic:
*   **Targeting:** The script looks for any node containing the string `"Desk_Row"` inside the `Placeholders` container.
*   **Scene Instancing:** It uses `PackedScene` variables to spawn objects. It is agnostic to the content of those scenes.
*   **Editor Tooling:** The script is marked with `@tool`, meaning you can trigger the spawn directly in the Godot Editor to see the results without playing the game.

## 3. How to Swap Placeholders for your FBX Models
When you download your manual FBX assets, follow these steps to update the entire office instantly:

### Option A: The "Direct Swap" (Recommended)
1.  Open the placeholder scene (e.g., `res://scenes/3d/props/Prop_Chair.tscn`).
2.  Delete the existing `MeshInstance3D` (the gray cube).
3.  Drag your **FBX file** from the FileSystem dock into the scene.
4.  Save the scene.
5.  **Result:** Every chair in the SOC is now your high-quality FBX model.

### Option B: The "Redirect"
1.  Import your FBX into Godot (let Godot create a `.tscn` for it).
2.  Select the `PropSpawner` node in the `SOC_Office` scene.
3.  Drag your new FBX-based `.tscn` into the corresponding slot (e.g., `Chair Scene`) in the Inspector.
4.  **Result:** The spawner will now use the new file for all future spawns.

## 4. Asset Preparation Checklist
To ensure your FBX models look correct when spawned, verify the following in your 3D software (Blender/Maya) or Godot Import settings:

*   **Pivot Point (Origin):** Set the origin to the **Bottom Center** of the object. If the origin is in the middle, the object will spawn half-sunk into the floor.
*   **Scale:** Ensure "1 Unit = 1 Meter". If your model is huge or tiny, adjust the `Import Scale` in the Godot Import dock.
*   **Forward Direction:** Godot uses **-Z** as forward. If your chairs face the wrong way, rotate the mesh inside the `Prop_...tscn` file.

## 5. Spawner Controls (Inspector)
Select the `PropSpawner` node to see these buttons:
*   **Trigger Spawn:** Regenerates all props in the editor.
*   **Clear Props:** Removes all generated props from the desks.
*   **Clutter Scenes:** An array where you can add new items (Mugs, Pizza Boxes, etc.) to the 40% random spawn logic.
