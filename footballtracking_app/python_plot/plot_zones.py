import json
import glob
import os
import numpy as np
import matplotlib.pyplot as plt

# 📂 Path to data folder (relative to this script)
BASE_DIR = os.path.dirname(__file__)
DATA_DIR = os.path.join(BASE_DIR, "data")

# 🔍 Find all player session files
files = glob.glob(os.path.join(DATA_DIR, "player_*_sessions.json"))

if not files:
    print("No player session files found in /data folder.")
    exit()

print(f"Found {len(files)} player files.\n")

for file_path in files:
    with open(file_path, "r", encoding="utf-8") as f:
        data = json.load(f)

    sessions = data.get("sessions", [])
    player_name = data.get("playerName", "Unknown Player")

    if not sessions:
        print(f"Skipping {player_name}: no sessions found.")
        continue

    low = np.mean([s["lowZonePercentage"] for s in sessions])
    ideal = np.mean([s["idealZonePercentage"] for s in sessions])
    high = np.mean([s["highZonePercentage"] for s in sessions])

    zones = ["Low", "Ideal", "High"]
    values = [low, ideal, high]

    plt.figure(figsize=(7, 5))
    plt.bar(zones, values)
    plt.ylabel("Percentage of Training Time (%)")
    plt.ylim(0, 100)
    plt.title(f"Average Time in Training Zones\n{player_name}")
    plt.grid(axis="y", linestyle="--", alpha=0.6)

    plt.show()
