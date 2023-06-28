""" Image Face Database Creator

usage: create_database [-h] [-i IMG_FOLDER] [-l LABEL_MAP_CSV] [-o OUTPUT_PATH]

Extracts the face from an image and saves it to a database of images, sorted by the identity of the face

optional arguments:
  -h, --help            show this help message and exit
  -i IMG_FOLDER, --img_folder IMG_FOLDER
                        Path to the folder of images
  -l LABEL_MAP_CSV, --label_map_csv LABEL_MAP_CSV
                        Path to the CSV of labels (file:label) pairs
  -o OUTPUT_PATH, --output_path OUTPUT_PATH
                        Path to folder which is the database
"""


import argparse
import os
import cv2
import pandas as pd
import uuid
from model_utils import get_detector, get_face_locations, get_largest_face_bb, save_bb_to_file
# import matplotlib.pyplot as plt


## GET ARGUMENTS


parser = argparse.ArgumentParser(
                    prog='create_database',
                    description='Extracts the face from an image and saves it to a database of images, sorted by the identity of the face',
                    epilog='Have a great one!')

parser.add_argument("-i", "--img_folder", type=str, help="Path to the folder of images")
parser.add_argument("-l", "--label_map_csv", type=str, help="Path to the CSV of labels (file:label) pairs")
parser.add_argument("-o", "--output_path", type=str, help="Path to folder which is the database")

args = parser.parse_args()
img_folder = args.img_folder
label_map_csv = args.label_map_csv
output = args.output_path


## MAIN


if __name__ == "__main__":

    face_detector = get_detector("haarcascade_frontalface_default.xml")
    labels_df = pd.read_csv(label_map_csv)


    for img in os.listdir(img_folder):
        if os.path.splitext(img)[1] not in [".jpg", ".png"]: continue

        img_path = os.path.join(img_folder, img)

        faces = get_face_locations(img_path, face_detector)

        face = get_largest_face_bb(faces)

        identity = labels_df[labels_df["file"]==img]["person_name"].values[0]

        identity_dir = os.path.join(output, identity)

        if not os.path.exists(identity_dir):
            os.mkdir(identity_dir)

        new_img_path = os.path.join(identity_dir, f"{identity}-{uuid.uuid4()}.jpg")

        save_bb_to_file(
            cv2.imread(img_path),
            face,
            new_img_path
        )

        print(f"Saved {new_img_path}")