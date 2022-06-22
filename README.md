# Grand débat national : une analyse automatique des contributions relatives aux transports

This repository contains source code to produce results and maps from the article 
_Grand débat national : une analyse automatique des contributions relatives aux transports_.

In this repo, you may find the following :
 
 * Train classifier to detect transportation related contributions
 * Extract opinion (prec. propositon) on transportation
 * Map the contribution on the metropolitan France

## Setup

First, we advise you to run the following on a Linux operating systems ! Else,
do not hesitate to run the code in a Google Collab repo. Except if you use Anaconda,
Python3.x must be installed on your machine.

Second, if you're not using colab, it is advised to use a virtual environment
to install required python modules. Be sure to check, `virtualenv` or the `conda` solution.

### Requirements

Required modules are indicated in the `requirements.txt` file. To install all
modules, run one of the following commands : 

using `conda`

    conda install --file requirements.txt

using `pip`

    pip install -r requirements.txt

You need language model from spacy, use the following commands to install them :

    python -m spacy download fr_core_news_sm
    python -m spacy download fr_core_news_lg

### Fetch required data

To fetch all the required data run the following commands:

    wget -O railroad_fr.geojson https://zenodo.org/record/4270184/files/railroad_fr.geojson?download=1
    wget -O trainstations.geojson https://zenodo.org/record/4270184/files/trainstations.geojson?download=1
    wget -O communes_importantes.geojson https://zenodo.org/record/4270184/files/communes_importantes.geojson?download=1
    wget -O bikeway_fr.geojson https://zenodo.org/record/4270184/files/bikeway_fr.geojson?download=1
    wget -O au2010_carto.geojson https://zenodo.org/record/4270184/files/au2010_carto.geojson?download=1
    wget -O motifs_with_geom.json https://zenodo.org/record/6671769/files/motifs_with_geom.json?download=1
    wget -O motifsxcommunes_without_geom.csv https://zenodo.org/record/6671769/files/motifsxcommunes_without_geom.csv?download=1
    wget -O communes_with_all_data.geojson https://zenodo.org/record/6671769/files/communes_with_all_data.geojson?download=1
    wget -O data_cadrage_meta.csv https://zenodo.org/record/6671769/files/data_cadrage_meta.csv?download=1
    wget -O LA_TRANSITION_ECOLOGIQUE.csv http://opendata.auth-6f31f706db6f4a24b55f42a6a79c5086.storage.sbg.cloud.ovh.net/2019-03-21/LA_TRANSITION_ECOLOGIQUE.csv

Here, you just need to get data from the ecological transition formular. However, you can extract proposition on other datasets available [here](https://granddebat.fr/pages/donnees-ouvertes).


## 1 - Train the classifier


To train the selected classifier in the paper, use the following command:
```bash
python train.py data/LA_TRANSITION_ECOLOGIQUE.csv data/results.csv -o -s
```

### Use the model on the whole dataset

```bash
python predict.py data/LA_TRANSITION_ECOLOGIQUE.csv 1 
```


## 2 - Extract propositions from the dataset

To extract the proposition in the data, use the following commands

```shell
python extract_patterns.py transition_eco "LA_TRANSITION_ECOLOGIQUE.csv"
python parse_pattern_output.py output_transition_eco/ transition_eco
python extract_keywords_in_pattern.py transition_eco_prop.csv
```

The output file will be saved in `transition_eco_prop_withkeywords_and_classes.csv`


## 3 - Map the contributions

To map the contribution, use the `contribution_mapping.py` script. For example:

    python contribution_mapping train charente map.png

You can use the `-h` to get help on how use the command. Basically, you can change the
geographic scope, either France or Charente-Maritimes, and the theme of the contribution
you wish to see on the map, either train or bicycle way developpement.

##  4 - Crossing extracted propositions and socio-economic features

For this one, you will need R software (https://www.r-project.org/). Then run the two R programs using the following command:

    Rscript Dicogeo.R
    Rscript graphiques.R

## Authors

Jacques Fize, Lucile Sautot, Mohamed Hilal, Ludovic Journaux, Martin Lentschat, Laurence Dujourdy
