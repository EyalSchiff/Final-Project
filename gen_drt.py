import random

# הגדרות
NUM_LINES = 512
NUM_BAD = 64

# 1. יצירת מערך DRT לכל התאים (5-20 מחזורי שעון)
drt_array = [random.randint(5, 100) for _ in range(NUM_LINES)]

# 2. מציאת הכתובות הגרועות (מערך של 64 כתובות)
# יוצרים רשימת זוגות של (כתובת, DRT) וממיינים לפי ה-DRT
indexed_drt = list(enumerate(drt_array))
indexed_drt.sort(key=lambda x: x[1])

# 64 הכתובות עם ה-DRT הכי קטן
bad_addresses = [item[0] for item in indexed_drt[:NUM_BAD]]

# 3. חישוב ה-DRT המינימלי החדש (הערך ה-65 ברשימה הממוינת)
# זה ה-DRT שקובע את קצב הרענון של ה-GCDRAM אחרי התיקון
new_min_drt = indexed_drt[NUM_BAD][1]

# --- הדפסות לבדיקה ---
print("--- Check Data ---")
print(f"First 10 DRT values: {drt_array[:]}")
print(f"First 10 Bad Addresses: {bad_addresses[:64]}")
print(f"Total Bad Addresses stored: {len(bad_addresses)}")
print("-" * 20)
print(f"Worst DRT in system (before fix): {indexed_drt[0][1]}")
print(f"New Minimum DRT (after moving 64 cells to SRAM): {new_min_drt}")

# שמירה לקבצים עבור ה-Verilog
with open("drt_times.mem", "w") as f:
    for val in drt_array: f.write(f"{val:x}\n")

with open("bad_addresses.mem", "w") as f:
    for addr in bad_addresses: f.write(f"{addr:x}\n")


    import os

# הקוד הזה מוצא את הנתיב המדויק שבו נמצא קובץ הפייתון כרגע
script_dir = os.path.dirname(os.path.abspath(__file__))

# חיבור הנתיב לשם הקובץ
path_drt = os.path.join(script_dir, "drt_times.mem")
path_bad = os.path.join(script_dir, "bad_addresses.mem")

with open(path_drt, "w") as f:
    for val in drt_array: 
        f.write(f"{val:x}\n")

with open(path_bad, "w") as f:
    for addr in bad_addresses: 
        f.write(f"{addr:x}\n")

print(f"Success! Files saved at: {script_dir}")