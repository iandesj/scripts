#!/usr/bin/env python

import os
import platform
from time import sleep

from selenium import webdriver
from selenium.webdriver.common.keys import Keys
from selenium.webdriver.chrome.options import Options

service = None
browser = None

try:
	# path to the binary of webdriver
	service = webdriver.chrome.service.Service('/usr/local/bin/chromedriver')  
	service.start()

	chrome_options = Options()  
	chrome_options.add_argument('--headless')  

	# path to the binary of Chrome
        if platform.system() is 'Darwin':
	    chrome_options.binary_location = '/Applications/Google\ Chrome.app/Contents/MacOS/Google\ Chrome'
        elif platform.system() is 'Linux':
	    chrome_options.binary_location = '/usr/bin/google-chrome-stable'


	print('Opening Chrome...')
	print('[###                          ]\n')
	browser = webdriver.Remote(service.service_url, desired_capabilities=chrome_options.to_capabilities())

	print('Opening `https://acc.vicex.io`...')
	print('[######                       ]\n')
	browser.get('https://acc.vicex.io')

	sleep(2)

	print('Sending email...')
	print('[#########                    ]\n')
	email = browser.find_element_by_id('email')
	email.send_keys(os.environ['VICEX_EMAIL'] + Keys.RETURN)

	sleep(2)

	print('Sending password...')
	print('[############                 ]\n')
	password = browser.find_element_by_id('password')
	password.send_keys(os.environ['VICEX_PASSWORD'] + Keys.TAB + Keys.RETURN)

	sleep(2)

	print('Opening `https://acc.vicex.io/acc/listing`...')
	print('[###############              ]\n')
	browser.get('https://acc.vicex.io/acc/listing')

	sleep(2)

	print('Expanding table rows to display 100...')
	print('[##################           ]\n')
	browser.find_element_by_css_selector('#DataTables_Table_0_length > label > select > option:nth-child(4)').click()

	sleep(2)

	print('Searching voting table...')
	print('[#####################        ]\n')
	table = browser.find_element_by_id('DataTables_Table_0')

	sleep(2)

	tbody = table.find_element_by_tag_name('tbody')

	sleep(2)

	akroma_row = None
	for row in tbody.find_elements_by_tag_name('tr'):
		if 'Akroma' in row.text:
			akroma_row = row
			break

	sleep(2)

	print('Voting!!')
	print('[########################     ]\n')
	button = akroma_row.find_element_by_tag_name('button')
	button_parent_div = button.find_element_by_xpath('..')

	sleep(2)

	button.click()

	sleep(2)

	if '+1 VOTE' in button_parent_div.text:
		print('Voting complete...')
	elif '+0 VOTE' in button_parent_div.text:
		print('Voting has already been completed for the day...')
	else:
		print('Error in voting...')

	print('Done...')
	print('[#############################]\n')

	browser.close()
	service.stop()
except KeyboardInterrupt:
	browser.close()
	service.stop()
