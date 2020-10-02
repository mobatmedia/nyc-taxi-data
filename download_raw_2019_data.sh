cat setup_files/raw_2019_data_urls.txt | xargs -n 1 -P 2 wget -c -P data/
