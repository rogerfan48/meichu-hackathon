import json
import sys
import os
from google.cloud import firestore

########################################################################
#       Upload Restaurant Data to Firestore                            #
# > set GOOGLE_APPLICATION_CREDENTIALS=C:\path\to\your\sa.json         #
# > python c:\WorkspaceFlutter\foodie\lib\data\upload_restaurant.py    #
#                                                                      #                         
########################################################################


# use a path relative to this file
JSON_PATH = os.path.normpath(
    os.path.join(os.path.dirname(__file__), 'restaurant_template.json')
)

def load_json(path: str):
    """Load and return JSON data from a file."""
    try:
        with open(path, 'r', encoding='utf-8') as f:
            data = json.load(f)
            count = len(data) if isinstance(data, list) else 1
            print(f"Loaded JSON from {path!r}, found {count} record(s).")
            return data
    except Exception as e:
        print(f"Failed to load JSON file: {e}", file=sys.stderr)
        sys.exit(1)

def upload_data(data):
    """Upload list or dict data to Firestore under 'apps/foodie/restaurants'."""
    db = firestore.Client(project='foodie-4dee6')
    print(f"Uploading to project: {db.project}")

    col = db.collection('apps').document('foodie').collection('restaurants')

    def _upload_restaurant(item):
        # detach menu for subcollection
        restaurant_data = dict(item)
        menu = restaurant_data.pop('menu', [])
        # upload restaurant document
        _, doc_ref = col.add(restaurant_data)
        print(f"    Uploaded restaurant '{restaurant_data.get('restaurantName')}' with ID: {doc_ref.id}")
        # upload each dish as subcollection 'menu'
        for dish in menu:
            _, dish_ref = doc_ref.collection('menu').add(dish)
            print(f"  → Added dish '{dish.get('dishName')}' under menu with ID: {dish_ref.id}")

    if isinstance(data, dict):
        _upload_restaurant(data)
    elif isinstance(data, list):
        for item in data:
            _upload_restaurant(item)
    else:
        print("JSON root must be a list or dict", file=sys.stderr)
        sys.exit(1)

    print("Upload complete.")

def main():
    # load from the relative JSON_PATH instead of parsing CLI args
    data = load_json(JSON_PATH)
    upload_data(data)

if __name__ == "__main__":
    main()