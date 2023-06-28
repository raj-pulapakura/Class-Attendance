import numpy as np
import cv2
import os
from tensorflow.keras.models import Model, Sequential
from tensorflow.keras.layers import Convolution2D, ZeroPadding2D, MaxPooling2D, Flatten, Dropout, Activation
from tensorflow.keras.preprocessing.image import load_img, img_to_array
from tensorflow.keras.applications.imagenet_utils import preprocess_input


def get_detector(path_to_detector):
    """
    Returns a face detector
    """
    face_detector = cv2.CascadeClassifier(path_to_detector)
    return face_detector


def get_face_locations(img_path, face_detector):
    """
    Returns the locations of all faces in an image

        img_path: Path to the image

        face_detector: A face detector
    """
    img = cv2.imread(img_path, cv2.COLOR_BGR2RGB)
    faces = face_detector.detectMultiScale(img)
    return list(faces)


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


def get_cropped_img(img_path, face_bb):
    """
    Crops out the bounding box (x, y, w, h) from an image and returns the cropped image

        img_path: Path to image

        face_bb: Bounding box of face (x, y, w, h)
    """
    img = cv2.imread(img_path, cv2.COLOR_BGR2RGB)
    (x, y, w, h) = face_bb
    cropped = img[y:y+h, x:x+w]
    return cropped


def get_database_embeddings(img_db_path, embedding_gen_net, target_size):
    """
    Gets the embeddings of the first sample of each identity in an image database.
    Embeddings are calculated through an embedding network.

        img_db_path: Path to the image database

        embedding_gen_net: Network which calculates the embeddings of an image

        target_size: Resolution to resize the image to in prepartion for inference
    """
    database_embeddings = {}
    for identity in os.listdir(img_db_path):
        sample = os.listdir(os.path.join(img_db_path, identity))[0]
        sample_path = os.path.join(img_db_path, identity, sample)
        image = cv2.imread(sample_path, cv2.COLOR_BGR2RGB)
        image = process_image_for_inference(image, target_size)

        database_embeddings[identity] = embedding_gen_net.predict(image)[0, :]
    return database_embeddings


def find_cosine_similarity(source_representation, test_representation):
    """
    Calculates the cosine similarity of two embeddings.

        source_representation: Embedding 1 (vector)

        test_representation: Embedding 2 (vector)
    """
    a = np.matmul(np.transpose(source_representation), test_representation)
    b = np.sum(np.multiply(source_representation, source_representation))
    c = np.sum(np.multiply(test_representation, test_representation))
    return 1 - (a / (np.sqrt(b) * np.sqrt(c)))


def process_image_for_inference(image, target_size):
    """
    Processes the image for inference by an embedding network.
    Resizes image and converts it to batch format.

        image: Image to process (array)

        target_size: Resolution to resize the image to in prepartion for inference
    """
    image = cv2.resize(image, target_size)
    image = np.expand_dims(image, axis = 0).astype(np.float64)
    image /= 255
    return image


def get_vgg_siamese_net(path_to_weights):
    """
    Creates a model based on the VGG architecture which calculates embeddings of an image.

        path_to_weights: Paths to the weights file (.h5)
    """

    model = Sequential()
    model.add(ZeroPadding2D((1,1),input_shape=(224,224, 3)))
    model.add(Convolution2D(64, (3, 3), activation='relu'))
    model.add(ZeroPadding2D((1,1)))
    model.add(Convolution2D(64, (3, 3), activation='relu'))
    model.add(MaxPooling2D((2,2), strides=(2,2)))

    model.add(ZeroPadding2D((1,1)))
    model.add(Convolution2D(128, (3, 3), activation='relu'))
    model.add(ZeroPadding2D((1,1)))
    model.add(Convolution2D(128, (3, 3), activation='relu'))
    model.add(MaxPooling2D((2,2), strides=(2,2)))

    model.add(ZeroPadding2D((1,1)))
    model.add(Convolution2D(256, (3, 3), activation='relu'))
    model.add(ZeroPadding2D((1,1)))
    model.add(Convolution2D(256, (3, 3), activation='relu'))
    model.add(ZeroPadding2D((1,1)))
    model.add(Convolution2D(256, (3, 3), activation='relu'))
    model.add(MaxPooling2D((2,2), strides=(2,2)))

    model.add(ZeroPadding2D((1,1)))
    model.add(Convolution2D(512, (3, 3), activation='relu'))
    model.add(ZeroPadding2D((1,1)))
    model.add(Convolution2D(512, (3, 3), activation='relu'))
    model.add(ZeroPadding2D((1,1)))
    model.add(Convolution2D(512, (3, 3), activation='relu'))
    model.add(MaxPooling2D((2,2), strides=(2,2)))

    model.add(ZeroPadding2D((1,1)))
    model.add(Convolution2D(512, (3, 3), activation='relu'))
    model.add(ZeroPadding2D((1,1)))
    model.add(Convolution2D(512, (3, 3), activation='relu'))
    model.add(ZeroPadding2D((1,1)))
    model.add(Convolution2D(512, (3, 3), activation='relu'))
    model.add(MaxPooling2D((2,2), strides=(2,2)))

    model.add(Convolution2D(4096, (7, 7), activation='relu'))
    model.add(Dropout(0.5))
    model.add(Convolution2D(4096, (1, 1), activation='relu'))
    model.add(Dropout(0.5))
    model.add(Convolution2D(2622, (1, 1)))
    model.add(Flatten())
    model.add(Activation('softmax'))

    model.load_weights(path_to_weights)
    vgg_siamese_net = Model(inputs=model.layers[0].input, outputs=model.layers[-2].output)
    print("VGG Siamese Network successfully created.")
    return vgg_siamese_net