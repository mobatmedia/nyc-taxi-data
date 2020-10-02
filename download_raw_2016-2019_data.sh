cat setup_files/raw_2016-2019_data_urls.txt | xargs -n 1 -P 6 wget -c -P data/
