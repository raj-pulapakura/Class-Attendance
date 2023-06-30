# Model testing

Here I develop scripts which simulate the face-detection technology which I will be using in the API.

## create_database.py

Creates a database of images which will be used to assign identities for face-detection requests.

Spec:

```
python create_database.py [-h] [-i IMG_FOLDER] [-l LABEL_MAP_CSV] [-o OUTPUT_PATH]

arguments:
  -h, --help            show this help message and exit
  -i IMG_FOLDER, --img_folder IMG_FOLDER
                        Path to the folder of images
  -l LABEL_MAP_CSV, --label_map_csv LABEL_MAP_CSV
                        Path to the CSV of labels (file:label) pairs
  -o OUTPUT_PATH, --output_path OUTPUT_PATH
                        Path to folder which is the database
```

Example usage:

```
python create_database.py -i original_imgs -l original_imgs/labels.csv -o img_database

>> Saved img_database\elon musk\elon musk-b4b02af0-1128-4d83-a717-375e89042f23.jpg
>> Saved img_database\elon musk\elon musk-228d62b7-5444-4889-b78e-22894fbeac89.jpg
>> Saved img_database\jeff bezos\jeff bezos-85df80c7-0644-4e6b-b346-8fbf28ec3cc8.jpg
>> Saved img_database\jeff bezos\jeff bezos-f909d687-3369-4d82-9972-5543a049ce4f.jpg
>> Saved img_database\steve jobs\steve jobs-89504ae1-7296-4b9a-96db-fab3d563fe69.jpg
>> Saved img_database\steve jobs\steve jobs-f61fab89-32de-4494-ae73-57fd1aad0d77.jpg
```

`[-i IMG_FOLDER]` refers to the folder containing all the images which will be contained within the database. In the _Example usage_, `original_imgs` is used, which looks like:

```
.
└── original_imgs/
    ├── elon 1.jpg
    ├── elon 2.jpg
    ├── jeff 1.jpg
    ├── jeff 2.jpg
    ├── jobs 1.jpg
    ├── jobs 2.jpg
    └── labels.csv
```

`[-l LABEL_MAP_CSV]` refers to a CSV file with 2 columns (`file`, `person_name`) which records the identities of each image in the `IMG_FOLDER`. In the _Example usage_, `original_imgs/labels.csv` is used, which looks like:

```csv
file,person_name
elon 1.jpg,elon musk
elon 2.jpg,elon musk
jeff 1.jpg,jeff bezos
jeff 2.jpg,jeff bezos
jobs 1.jpg,steve jobs
jobs 2.jpg,steve jobs
```

`[-o OUTPUT_PATH]` refers to the folder where the database will be created. If it does not exist, it will be created. In the _Example Usage_, `img_database` is used.

## identify_face.py

Identifies an image of a face based on a database of identities.

Spec:

```
python identify_face.py [-h] [-i IMG_DB] [-t TEST_IMG]

arguments:
  -h, --help            show this help message and exit
  -i IMG_DB_PATH, --img_db_path IMG_DB_PATH
                        Path to the image database
  -t TEST_IMG_PATH, --test_img_path TEST_IMG_PATH
                        Path to the image which needs to be identified
```

Example usage:

```
python identify_face.py -i "img_database" -t "test_imgs/elon musk/elon-test.jpg"

>> VGG Siamese Network successfully created.
>> 1/1 [==============================] - 1s 511ms/step
>> 1/1 [==============================] - 0s 183ms/step
>> 1/1 [==============================] - 0s 229ms/step
>> Loaded database embeddings.
>> 3 identities found.
>> 1/1 [==============================] - 0s 233ms/step
>> Determined identity: elon musk
>> Process took 5.25s
```

`[-i IMG_DB]` refers to the database of images, created using the `create_database.py` script. In the _Example usage_, `"img_database"` is used, which looks like:

```
.
└── img_database/
    ├── elon musk/
    │   ├── elon musk-228d62b7-5444-4889-b78e-22894fbeac89.jpg
    │   └── elon musk-b4b02af0-1128-4d83-a717-375e89042f23.jpg
    ├── jeff bezos/
    │   ├── jeff bezos-85df80c7-0644-4e6b-b346-8fbf28ec3cc8.jpg
    │   └── jeff bezos-f909d687-3369-4d82-9972-5543a049ce4f.jpg
    └── steve jobs/
        ├── steve jobs-89504ae1-7296-4b9a-96db-fab3d563fe69.jpg
        └── steve jobs-f61fab89-32de-4494-ae73-57fd1aad0d77.jpg
```

`[-t TEST_IMG]` refers to image you want to identify. In the _Example usage_, `"test_imgs/elon musk/elon-test.jpg"` is used.
