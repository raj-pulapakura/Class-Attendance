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


## HELPER FUNCTIONS


def get_detector():
    """
    Returns a face detector
    """
    face_detector = cv2.CascadeClassifier('haarcascade_frontalface_default.xml')
    return face_detector


def get_face_locations(img_path, face_detector):
    """
    Returns the locations of all faces in an image

        img_path: Path to the image

        face_detector: A face detector
    """
    img = cv2.imread(img_path, cv2.COLOR_BGR2RGB)
    faces = face_detector.detectMultiScale(img)
    return faces


def get_largest_face_bb(faces):
    """
    Returns the largest face bounding box by area

        faces: list of face bounding boxes (x, y, w, h)
    """
    # sort faces by decreasing area (width*height)
    faces.sort(key=lambda face: face[2]*face[3], reverse=True)
    # return largest face by area
    return faces[0]


def draw_face_locations(faces, img_path, only_draw_largest=False):
    """
    Returns an editted image with all face bounding boxes drawn

        faces: list of face bounding boxes (x, y, w, h)

        img_path: Path to image

        only_draw_largest: Bool determining whether only the largest face by area should be drawn 
    """
    img = cv2.imread(img_path, cv2.COLOR_BGR2RGB)
    if only_draw_largest:
        (x, y, w, h) = get_largest_face_bb(faces)
        cv2.rectangle(img, (x, y), (x+w, y+h), (0, 255, 0), 2)
    else:
        for (x, y, w, h) in faces:
            cv2.rectangle(img, (x, y), (x+w, y+h), (0, 255, 0), 2)
    return img


def save_bb_to_file(img, face_bb, filename):
    """
    Saves only the bounding box portion of an image to a file

        img: Path to image

        face_bb: Bounding box of face (x, y, w, h)

        filename: Path where the cropped image should be saved
    """
    (x, y, w, h) = face_bb
    img = img[y:y+h, x:x+w]
    cv2.imwrite(filename, img)


## MAIN


if __name__ == "__main__":

    face_detector = get_detector()
    labels_df = pd.read_csv(label_map_csv)


    for img in os.listdir(img_folder):
        if os.path.splitext(img)[1] not in [".jpg", ".png"]: continue

        img_path = os.path.join(img_folder, img)

        faces = list(get_face_locations(img_path, face_detector))

        # drawn_faces = draw_face_locations(faces, img_path, only_draw_largest=True)
        # plt.imshow(drawn_faces)
        # plt.show()

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