"""Image Face Detection and Identificiation

usage: identify_face [-h] [-i IMG_DB] [-t TEST_IMG]

Matches an image of a face to an identity in a database of images

optional arguments:
  -h, --help            show this help message and exit
  -i IMG_DB_PATH, --img_db_path IMG_DB_PATH
                        Path to the image database
  -t TEST_IMG_PATH, --test_img_path TEST_IMG_PATH
                        Path to the image which needs to be identified
"""


import argparse
import numpy as np
from model_utils import get_vgg_siamese_net, process_image_for_inference, get_database_embeddings, get_detector, get_face_locations, get_largest_face_bb, get_cropped_img, find_cosine_similarity
import time


## GET ARGUMENTS


parser = argparse.ArgumentParser(
                    prog='identify_face',
                    description='Matches an image of a face to an identity in a database of images',
                    epilog='Have a great one!')

parser.add_argument("-i", "--img_db_path", type=str, help="Path to the image database")
parser.add_argument("-t", "--test_img_path", type=str, help="Path to the image which needs to be identified")

args = parser.parse_args()
img_db_path = args.img_db_path
test_img_path = args.test_img_path



## MAIN


if __name__ == "__main__":
    start = time.time()
    vgg_siamese_net = get_vgg_siamese_net("vgg_weights.h5")
    target_size = (224, 224)

    database_embeddings = get_database_embeddings(img_db_path, vgg_siamese_net, target_size)
    print("Loaded database embeddings.")
    print(f"{len(database_embeddings.keys())} identities found.")

    face_detector = get_detector("haarcascade_frontalface_default.xml")
    faces = get_face_locations(test_img_path, face_detector)
    face = get_largest_face_bb(faces)

    cropped_img = get_cropped_img(test_img_path, face)
    test_img = process_image_for_inference(cropped_img, target_size)

    test_img_embeddings = vgg_siamese_net.predict(test_img)[0, :]

    matched_identity = ""
    matched_sim_score = np.inf

    for identity, embeddings in database_embeddings.items():
        sim_score = find_cosine_similarity(test_img_embeddings, embeddings)
        if sim_score < matched_sim_score:
            matched_sim_score = sim_score
            matched_identity = identity

    print(f"Determined identity: {matched_identity}")
    end = time.time()
    print(f"Process took {round(end-start, 2)}s")