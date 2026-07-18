/// Complete Bangladesh location hierarchy for the DwellWise search filters.
///
/// Structure: Division -> District -> list of Thanas / Upazilas.
/// All 8 divisions and all 64 districts are included, with the real
/// thana/upazila list under each district. For Dhaka city and the major
/// metro cities, curated real neighbourhood ("area") lists are provided in
/// [bdThanaAreas] keyed as 'District|Thana'. Thanas without a curated list
/// fall back to '<Thana> Sadar' / '<Thana> Bazar' via [areasForThana].
library bd_locations;

const Map<String, Map<String, List<String>>> bdDivisions = {
  'Dhaka': {
    'Dhaka': [
      // Dhaka Metropolitan (DMP) thanas
      'Adabor', 'Badda', 'Banani', 'Bangshal', 'Bhashantek', 'Cantonment',
      'Chawkbazar', 'Dakshinkhan', 'Demra', 'Dhanmondi', 'Gendaria', 'Gulshan',
      'Hatirjheel', 'Hazaribagh', 'Jatrabari', 'Kadamtali', 'Kafrul',
      'Kalabagan', 'Kamrangirchar', 'Khilgaon', 'Khilkhet', 'Kotwali',
      'Lalbagh', 'Mirpur Model', 'Mohammadpur', 'Motijheel', 'Mugda',
      'New Market', 'Pallabi', 'Paltan', 'Ramna', 'Rampura', 'Sabujbagh',
      'Shah Ali', 'Shahbagh', 'Sher-e-Bangla Nagar', 'Shyampur', 'Sutrapur',
      'Tejgaon', 'Turag', 'Uttara East', 'Uttara West', 'Uttarkhan', 'Vatara',
      'Wari',
      // Dhaka district upazilas outside the metro
      'Dhamrai', 'Dohar', 'Keraniganj', 'Nawabganj', 'Savar',
    ],
    'Faridpur': [
      'Faridpur Sadar', 'Alfadanga', 'Bhanga', 'Boalmari', 'Charbhadrasan',
      'Madhukhali', 'Nagarkanda', 'Sadarpur', 'Saltha',
    ],
    'Gazipur': [
      'Gazipur Sadar', 'Tongi', 'Kaliakair', 'Kaliganj', 'Kapasia', 'Sreepur',
    ],
    'Gopalganj': [
      'Gopalganj Sadar', 'Kashiani', 'Kotalipara', 'Muksudpur', 'Tungipara',
    ],
    'Kishoreganj': [
      'Kishoreganj Sadar', 'Austagram', 'Bajitpur', 'Bhairab', 'Hossainpur',
      'Itna', 'Karimganj', 'Katiadi', 'Kuliarchar', 'Mithamain', 'Nikli',
      'Pakundia', 'Tarail',
    ],
    'Madaripur': [
      'Madaripur Sadar', 'Dasar', 'Kalkini', 'Rajoir', 'Shibchar',
    ],
    'Manikganj': [
      'Manikganj Sadar', 'Daulatpur', 'Ghior', 'Harirampur', 'Saturia',
      'Shivalaya', 'Singair',
    ],
    'Munshiganj': [
      'Munshiganj Sadar', 'Gazaria', 'Lohajang', 'Sirajdikhan', 'Sreenagar',
      'Tongibari',
    ],
    'Narayanganj': [
      'Narayanganj Sadar', 'Fatullah', 'Siddhirganj', 'Araihazar', 'Bandar',
      'Rupganj', 'Sonargaon',
    ],
    'Narsingdi': [
      'Narsingdi Sadar', 'Belabo', 'Monohardi', 'Palash', 'Raipura', 'Shibpur',
    ],
    'Rajbari': [
      'Rajbari Sadar', 'Baliakandi', 'Goalandaghat', 'Kalukhali', 'Pangsha',
    ],
    'Shariatpur': [
      'Shariatpur Sadar', 'Bhedarganj', 'Damudya', 'Gosairhat', 'Naria',
      'Zajira',
    ],
    'Tangail': [
      'Tangail Sadar', 'Basail', 'Bhuapur', 'Delduar', 'Dhanbari', 'Ghatail',
      'Gopalpur', 'Kalihati', 'Madhupur', 'Mirzapur', 'Nagarpur', 'Sakhipur',
    ],
  },
  'Chattogram': {
    'Chattogram': [
      // Chattogram Metropolitan (CMP) thanas
      'Akbarshah', 'Bakalia', 'Bandar', 'Bayazid', 'Chandgaon',
      'Chattogram Kotwali', 'Double Mooring', 'Halishahar', 'Khulshi',
      'Pahartali', 'Panchlaish', 'Patenga',
      // District upazilas
      'Anwara', 'Banshkhali', 'Boalkhali', 'Chandanaish', 'Fatikchhari',
      'Hathazari', 'Karnaphuli', 'Lohagara', 'Mirsharai', 'Patiya',
      'Rangunia', 'Raozan', 'Sandwip', 'Satkania', 'Sitakunda',
    ],
    'Bandarban': [
      'Bandarban Sadar', 'Alikadam', 'Lama', 'Naikhongchhari', 'Rowangchhari',
      'Ruma', 'Thanchi',
    ],
    'Brahmanbaria': [
      'Brahmanbaria Sadar', 'Akhaura', 'Ashuganj', 'Bancharampur',
      'Bijoynagar', 'Kasba', 'Nabinagar', 'Nasirnagar', 'Sarail',
    ],
    'Chandpur': [
      'Chandpur Sadar', 'Faridganj', 'Haimchar', 'Haziganj', 'Kachua',
      'Matlab Dakshin', 'Matlab Uttar', 'Shahrasti',
    ],
    'Cumilla': [
      'Cumilla Adarsha Sadar', 'Cumilla Sadar Dakshin', 'Barura',
      'Brahmanpara', 'Burichang', 'Chandina', 'Chauddagram', 'Daudkandi',
      'Debidwar', 'Homna', 'Laksam', 'Lalmai', 'Meghna', 'Monohorgonj',
      'Muradnagar', 'Nangalkot', 'Titas',
    ],
    'Cox\'s Bazar': [
      'Cox\'s Bazar Sadar', 'Chakaria', 'Eidgaon', 'Kutubdia', 'Maheshkhali',
      'Pekua', 'Ramu', 'Teknaf', 'Ukhia',
    ],
    'Feni': [
      'Feni Sadar', 'Chhagalnaiya', 'Daganbhuiyan', 'Fulgazi', 'Parshuram',
      'Sonagazi',
    ],
    'Khagrachhari': [
      'Khagrachhari Sadar', 'Dighinala', 'Guimara', 'Lakshmichhari',
      'Mahalchhari', 'Manikchhari', 'Matiranga', 'Panchhari', 'Ramgarh',
    ],
    'Lakshmipur': [
      'Lakshmipur Sadar', 'Kamalnagar', 'Raipur', 'Ramganj', 'Ramgati',
    ],
    'Noakhali': [
      'Noakhali Sadar', 'Begumganj', 'Chatkhil', 'Companiganj', 'Hatiya',
      'Kabirhat', 'Senbagh', 'Sonaimuri', 'Subarnachar',
    ],
    'Rangamati': [
      'Rangamati Sadar', 'Baghaichhari', 'Barkal', 'Belaichhari',
      'Juraichhari', 'Kaptai', 'Kawkhali', 'Langadu', 'Naniarchar',
      'Rajasthali',
    ],
  },
  'Rajshahi': {
    'Rajshahi': [
      // Rajshahi Metropolitan (RMP) thanas
      'Boalia', 'Motihar', 'Rajpara', 'Shah Makhdum',
      // District upazilas
      'Bagha', 'Bagmara', 'Charghat', 'Durgapur', 'Godagari', 'Mohanpur',
      'Paba', 'Puthia', 'Tanore',
    ],
    'Bogura': [
      'Bogura Sadar', 'Adamdighi', 'Dhunat', 'Dhupchanchia', 'Gabtali',
      'Kahaloo', 'Nandigram', 'Sariakandi', 'Shajahanpur', 'Sherpur',
      'Shibganj', 'Sonatala',
    ],
    'Chapainawabganj': [
      'Chapainawabganj Sadar', 'Bholahat', 'Gomastapur', 'Nachole',
      'Shibganj',
    ],
    'Joypurhat': [
      'Joypurhat Sadar', 'Akkelpur', 'Kalai', 'Khetlal', 'Panchbibi',
    ],
    'Naogaon': [
      'Naogaon Sadar', 'Atrai', 'Badalgachhi', 'Dhamoirhat', 'Mahadebpur',
      'Manda', 'Niamatpur', 'Patnitala', 'Porsha', 'Raninagar', 'Sapahar',
    ],
    'Natore': [
      'Natore Sadar', 'Bagatipara', 'Baraigram', 'Gurudaspur', 'Lalpur',
      'Naldanga', 'Singra',
    ],
    'Pabna': [
      'Pabna Sadar', 'Atgharia', 'Bera', 'Bhangura', 'Chatmohar',
      'Faridpur', 'Ishwardi', 'Santhia', 'Sujanagar',
    ],
    'Sirajganj': [
      'Sirajganj Sadar', 'Belkuchi', 'Chauhali', 'Kamarkhanda', 'Kazipur',
      'Raiganj', 'Shahjadpur', 'Tarash', 'Ullahpara',
    ],
  },
  'Khulna': {
    'Khulna': [
      // Khulna Metropolitan (KMP) thanas
      'Khulna Sadar', 'Sonadanga', 'Khalishpur', 'Daulatpur',
      'Khan Jahan Ali', 'Harintana', 'Labanchara', 'Aranghata',
      // District upazilas
      'Batiaghata', 'Dacope', 'Dighalia', 'Dumuria', 'Koyra', 'Paikgachha',
      'Phultala', 'Rupsha', 'Terokhada',
    ],
    'Bagerhat': [
      'Bagerhat Sadar', 'Chitalmari', 'Fakirhat', 'Kachua', 'Mollahat',
      'Mongla', 'Morrelganj', 'Rampal', 'Sarankhola',
    ],
    'Chuadanga': [
      'Chuadanga Sadar', 'Alamdanga', 'Damurhuda', 'Jibannagar',
    ],
    'Jashore': [
      'Jashore Sadar', 'Abhaynagar', 'Bagherpara', 'Chaugachha',
      'Jhikargachha', 'Keshabpur', 'Manirampur', 'Sharsha',
    ],
    'Jhenaidah': [
      'Jhenaidah Sadar', 'Harinakunda', 'Kaliganj', 'Kotchandpur',
      'Maheshpur', 'Shailkupa',
    ],
    'Kushtia': [
      'Kushtia Sadar', 'Bheramara', 'Daulatpur', 'Khoksa', 'Kumarkhali',
      'Mirpur',
    ],
    'Magura': [
      'Magura Sadar', 'Mohammadpur', 'Shalikha', 'Sreepur',
    ],
    'Meherpur': [
      'Meherpur Sadar', 'Gangni', 'Mujibnagar',
    ],
    'Narail': [
      'Narail Sadar', 'Kalia', 'Lohagara',
    ],
    'Satkhira': [
      'Satkhira Sadar', 'Assasuni', 'Debhata', 'Kalaroa', 'Kaliganj',
      'Shyamnagar', 'Tala',
    ],
  },
  'Barishal': {
    'Barishal': [
      // Barishal Metropolitan (BMP) thanas
      'Kotwali (Barishal)', 'Airport (Barishal)', 'Bandar (Barishal)',
      'Kawnia',
      // District upazilas
      'Agailjhara', 'Babuganj', 'Bakerganj', 'Banaripara', 'Gaurnadi',
      'Hizla', 'Mehendiganj', 'Muladi', 'Wazirpur',
    ],
    'Barguna': [
      'Barguna Sadar', 'Amtali', 'Bamna', 'Betagi', 'Patharghata', 'Taltali',
    ],
    'Bhola': [
      'Bhola Sadar', 'Borhanuddin', 'Char Fasson', 'Daulatkhan', 'Lalmohan',
      'Manpura', 'Tazumuddin',
    ],
    'Jhalokathi': [
      'Jhalokathi Sadar', 'Kathalia', 'Nalchity', 'Rajapur',
    ],
    'Patuakhali': [
      'Patuakhali Sadar', 'Bauphal', 'Dashmina', 'Dumki', 'Galachipa',
      'Kalapara', 'Mirzaganj', 'Rangabali',
    ],
    'Pirojpur': [
      'Pirojpur Sadar', 'Bhandaria', 'Indurkani', 'Kawkhali', 'Mathbaria',
      'Nazirpur', 'Nesarabad',
    ],
  },
  'Sylhet': {
    'Sylhet': [
      // Sylhet Metropolitan (SMP) thanas
      'Sylhet Kotwali', 'Airport (Sylhet)', 'Dakshin Surma', 'Jalalabad',
      'Moglabazar', 'Shahporan',
      // District upazilas
      'Balaganj', 'Beanibazar', 'Bishwanath', 'Companiganj', 'Fenchuganj',
      'Golapganj', 'Gowainghat', 'Jaintiapur', 'Kanaighat', 'Osmani Nagar',
      'Zakiganj',
    ],
    'Habiganj': [
      'Habiganj Sadar', 'Ajmiriganj', 'Bahubal', 'Baniyachong',
      'Chunarughat', 'Lakhai', 'Madhabpur', 'Nabiganj', 'Shayestaganj',
    ],
    'Moulvibazar': [
      'Moulvibazar Sadar', 'Barlekha', 'Juri', 'Kamalganj', 'Kulaura',
      'Rajnagar', 'Sreemangal',
    ],
    'Sunamganj': [
      'Sunamganj Sadar', 'Bishwamvarpur', 'Chhatak', 'Derai', 'Dharampasha',
      'Dowarabazar', 'Jagannathpur', 'Jamalganj', 'Madhyanagar',
      'Shantiganj', 'Sullah', 'Tahirpur',
    ],
  },
  'Rangpur': {
    'Rangpur': [
      // Rangpur Metropolitan thanas
      'Rangpur Kotwali', 'Mahiganj', 'Haragach', 'Tajhat',
      // District upazilas
      'Badarganj', 'Gangachara', 'Kaunia', 'Mithapukur', 'Pirgachha',
      'Pirganj', 'Taraganj',
    ],
    'Dinajpur': [
      'Dinajpur Sadar', 'Birampur', 'Birganj', 'Biral', 'Bochaganj',
      'Chirirbandar', 'Fulbari', 'Ghoraghat', 'Hakimpur', 'Kaharole',
      'Khansama', 'Nawabganj', 'Parbatipur',
    ],
    'Gaibandha': [
      'Gaibandha Sadar', 'Fulchhari', 'Gobindaganj', 'Palashbari',
      'Sadullapur', 'Saghata', 'Sundarganj',
    ],
    'Kurigram': [
      'Kurigram Sadar', 'Bhurungamari', 'Char Rajibpur', 'Chilmari',
      'Nageshwari', 'Phulbari', 'Rajarhat', 'Raomari', 'Ulipur',
    ],
    'Lalmonirhat': [
      'Lalmonirhat Sadar', 'Aditmari', 'Hatibandha', 'Kaliganj', 'Patgram',
    ],
    'Nilphamari': [
      'Nilphamari Sadar', 'Dimla', 'Domar', 'Jaldhaka', 'Kishoreganj',
      'Saidpur',
    ],
    'Panchagarh': [
      'Panchagarh Sadar', 'Atwari', 'Boda', 'Debiganj', 'Tetulia',
    ],
    'Thakurgaon': [
      'Thakurgaon Sadar', 'Baliadangi', 'Haripur', 'Pirganj', 'Ranisankail',
    ],
  },
  'Mymensingh': {
    'Mymensingh': [
      'Mymensingh Sadar', 'Bhaluka', 'Dhobaura', 'Fulbaria', 'Gafargaon',
      'Gauripur', 'Haluaghat', 'Ishwarganj', 'Muktagachha', 'Nandail',
      'Phulpur', 'Tara Khanda', 'Trishal',
    ],
    'Jamalpur': [
      'Jamalpur Sadar', 'Baksiganj', 'Dewanganj', 'Islampur', 'Madarganj',
      'Melandaha', 'Sarishabari',
    ],
    'Netrokona': [
      'Netrokona Sadar', 'Atpara', 'Barhatta', 'Durgapur', 'Kalmakanda',
      'Kendua', 'Khaliajuri', 'Madan', 'Mohanganj', 'Purbadhala',
    ],
    'Sherpur': [
      'Sherpur Sadar', 'Jhenaigati', 'Nakla', 'Nalitabari', 'Sreebardi',
    ],
  },
};

/// Curated real neighbourhood lists, keyed 'District|Thana'.
/// Thanas not listed here fall back to '<Thana> Sadar' / '<Thana> Bazar'.
const Map<String, List<String>> bdThanaAreas = {
  // ---------------- DHAKA CITY (DMP) ----------------
  'Dhaka|Pallabi': [
    'Mirpur 10', 'Mirpur 11', 'Mirpur 11.5', 'Mirpur 12', 'Kalshi',
    'Mirpur DOHS', 'Rupnagar', 'Eastern Housing', 'Alubdi',
  ],
  'Dhaka|Mirpur Model': [
    'Mirpur 1', 'Mirpur 2', 'Mirpur 6', 'Mirpur 7', 'Mirpur 10',
    'Shah Ali Bag', 'Tolarbag', 'Paikpara', 'Kazipara', 'Sheorapara',
  ],
  'Dhaka|Kafrul': [
    'Mirpur 13', 'Mirpur 14', 'Kachukhet', 'Ibrahimpur', 'West Kafrul',
    'Senpara Parbata',
  ],
  'Dhaka|Shah Ali': [
    'Mirpur Mazar Road', 'Gudaraghat', 'Diabari (Mirpur)', 'Beribadh',
    'Eastern Housing 2nd Phase',
  ],
  'Dhaka|Bhashantek': [
    'Bhashantek', 'Matikata', 'Damalkot', 'Dewanpara',
  ],
  'Dhaka|Cantonment': [
    'Dhaka Cantonment', 'ECB Chattar', 'Manikdi', 'Balughat', 'Vashantek Road',
  ],
  'Dhaka|Gulshan': [
    'Gulshan 1', 'Gulshan 2', 'Niketan', 'Baridhara Diplomatic Zone',
    'Gulshan Avenue',
  ],
  'Dhaka|Banani': [
    'Banani', 'Banani DOHS', 'Kakoli', 'Banani Block E', 'Banani Block H',
  ],
  'Dhaka|Vatara': [
    'Bashundhara R/A', 'Baridhara J Block', 'Notun Bazar', 'Khilbarirtek',
    'Coca-Cola Mor',
  ],
  'Dhaka|Badda': [
    'Middle Badda', 'North Badda', 'South Badda', 'Merul Badda', 'Shahjadpur',
    'Aftabnagar',
  ],
  'Dhaka|Rampura': [
    'West Rampura', 'East Rampura', 'Banasree', 'Ulon', 'Wapda Road',
  ],
  'Dhaka|Khilgaon': [
    'Khilgaon', 'Taltola (Khilgaon)', 'Goran', 'Tilpapara', 'Meradia',
  ],
  'Dhaka|Sabujbagh': [
    'Basabo', 'Madartek', 'Ahmedbag', 'Rajarbag',
  ],
  'Dhaka|Mugda': [
    'Mugda', 'Manda', 'Green Model Town', 'Mandail',
  ],
  'Dhaka|Motijheel': [
    'Motijheel', 'Arambagh', 'Fakirapool', 'Dilkusha', 'Kamalapur',
  ],
  'Dhaka|Paltan': [
    'Purana Paltan', 'Naya Paltan', 'Bijoynagar', 'Segunbagicha',
  ],
  'Dhaka|Ramna': [
    'Eskaton', 'Bailey Road', 'Kakrail', 'Siddheswari', 'Minto Road',
  ],
  'Dhaka|Hatirjheel': [
    'Moghbazar', 'Madhubag', 'Mirbagh', 'Nayatola',
  ],
  'Dhaka|Tejgaon': [
    'Farmgate', 'Tejkunipara', 'Nakhalpara', 'Tejturi Bazar',
    'Tejgaon Industrial Area',
  ],
  'Dhaka|Sher-e-Bangla Nagar': [
    'Agargaon', 'Taltola (Agargaon)', 'Manipuri Para', 'Sangsad Bhaban Area',
  ],
  'Dhaka|Mohammadpur': [
    'Mohammadpur', 'Shyamoli', 'Nurjahan Road', 'Iqbal Road', 'Bosila',
    'Tajmahal Road', 'Krishi Market',
  ],
  'Dhaka|Adabor': [
    'Adabor', 'Shekhertek', 'Mohammadia Housing', 'Baitul Aman Housing',
  ],
  'Dhaka|Dhanmondi': [
    'Dhanmondi 27', 'Dhanmondi 32', 'Dhanmondi 8A', 'Jigatola', 'Sobhanbag',
    'Shankar',
  ],
  'Dhaka|Kalabagan': [
    'Kalabagan', 'Panthapath', 'Lake Circus', 'Crescent Road',
  ],
  'Dhaka|Hazaribagh': [
    'Hazaribagh', 'Jhauchar', 'Gonoktuli', 'Company Ghat',
  ],
  'Dhaka|Lalbagh': [
    'Lalbagh', 'Azimpur', 'Shahid Nagar', 'Islambagh',
  ],
  'Dhaka|New Market': [
    'New Market', 'Nilkhet', 'Elephant Road', 'Katabon',
  ],
  'Dhaka|Shahbagh': [
    'Shahbagh', 'Paribagh', 'Hatirpool', 'Kataban Mor',
  ],
  'Dhaka|Kotwali': [
    'Sadarghat', 'Islampur', 'Patuatuli', 'Babubazar',
  ],
  'Dhaka|Sutrapur': [
    'Sutrapur', 'Laxmibazar', 'Farashganj', 'Bania Nagar',
  ],
  'Dhaka|Gendaria': [
    'Gendaria', 'Dholairpar', 'Faridabad', 'Sutrapur Road',
  ],
  'Dhaka|Wari': [
    'Wari', 'Rankin Street', 'Tikatuli', 'Larmini Street',
  ],
  'Dhaka|Bangshal': [
    'Bangshal', 'Nazira Bazar', 'Alu Bazar', 'Siddique Bazar',
  ],
  'Dhaka|Chawkbazar': [
    'Chawkbazar', 'Bakshibazar', 'Urdu Road', 'Begum Bazar',
  ],
  'Dhaka|Kamrangirchar': [
    'Kamrangirchar', 'Kholamora', 'Ashrafabad',
  ],
  'Dhaka|Jatrabari': [
    'Jatrabari', 'Shonir Akhra', 'Dhania', 'Sayedabad', 'Kajla',
  ],
  'Dhaka|Demra': [
    'Demra', 'Sarulia', 'Konapara', 'Staff Quarter',
  ],
  'Dhaka|Shyampur': [
    'Shyampur', 'Postogola', 'Jurain', 'Karimullabag',
  ],
  'Dhaka|Kadamtali': [
    'Rayerbag', 'Muradpur (Dhaka)', 'Jurain Rail Gate',
  ],
  'Dhaka|Uttara East': [
    'Sector 1', 'Sector 3', 'Sector 4', 'Sector 5', 'Sector 7', 'Sector 9',
    'Sector 11',
  ],
  'Dhaka|Uttara West': [
    'Sector 10', 'Sector 12', 'Sector 13', 'Sector 14', 'Sector 17',
    'Sector 18 (Rajuk Uttara)',
  ],
  'Dhaka|Uttarkhan': [
    'Uttarkhan', 'Mausair', 'Fayedabad',
  ],
  'Dhaka|Dakshinkhan': [
    'Dakshinkhan', 'Ashkona', 'Gawair', 'Holan',
  ],
  'Dhaka|Turag': [
    'Kamarpara', 'Dhour', 'Nayanagar', 'Rana Bhola',
  ],
  'Dhaka|Khilkhet': [
    'Khilkhet', 'Nikunja 1', 'Nikunja 2', 'Lake City Concord', 'Namapara',
  ],
  'Dhaka|Savar': [
    'Savar Bazar', 'Hemayetpur', 'Ashulia', 'Jahangirnagar', 'Radio Colony',
    'Genda',
  ],
  'Dhaka|Keraniganj': [
    'Zinzira', 'Ati Bazar', 'Kadamtali (Keraniganj)', 'Hasnabad',
  ],
  // ---------------- GAZIPUR ----------------
  'Gazipur|Gazipur Sadar': [
    'Joydebpur', 'Chowrasta', 'Board Bazar', 'Salna', 'Bhawal',
  ],
  'Gazipur|Tongi': [
    'Tongi Bazar', 'Cherag Ali', 'College Gate', 'Station Road (Tongi)',
    'Ershad Nagar',
  ],
  // ---------------- NARAYANGANJ ----------------
  'Narayanganj|Narayanganj Sadar': [
    'Chashara', 'Kalir Bazar', 'Tanbazar', 'Khanpur', 'Amlapara',
  ],
  'Narayanganj|Fatullah': [
    'Fatullah', 'Panchabati', 'Isdair', 'Masdair',
  ],
  'Narayanganj|Siddhirganj': [
    'Siddhirganj', 'Chittagong Road', 'Adamjee EPZ Area', 'Hirajheel',
  ],
  // ---------------- CHATTOGRAM CITY (CMP) ----------------
  'Chattogram|Chattogram Kotwali': [
    'Anderkilla', 'Jamal Khan', 'Lalkhan Bazar', 'Firingee Bazar',
    'New Market (Ctg)',
  ],
  'Chattogram|Panchlaish': [
    'Panchlaish R/A', 'Nasirabad', 'Muradpur', 'Katalganj', 'O R Nizam Road',
  ],
  'Chattogram|Double Mooring': [
    'Agrabad', 'Dewanhat', 'Chowmuhani (Ctg)', 'Monsurabad',
  ],
  'Chattogram|Khulshi': [
    'Khulshi', 'South Khulshi', 'Jhautola', 'Ambagan', 'Foy\'s Lake Area',
  ],
  'Chattogram|Halishahar': [
    'Halishahar Housing Estate', 'Agrabad Access Road', 'Baraipara',
    'Chowdhurypara',
  ],
  'Chattogram|Chandgaon': [
    'Chandgaon R/A', 'Bahaddarhat', 'Kaptai Rastar Matha', 'Mohara',
  ],
  'Chattogram|Bayazid': [
    'Bayazid Bostami', 'Oxygen', 'Sholoshohor', 'Hill View R/A',
  ],
  'Chattogram|Pahartali': [
    'Pahartali', 'Dattapara', 'Sagorika', 'Katgor',
  ],
  'Chattogram|Bandar': [
    'Bandar', 'Nimtala', 'Saltgola', 'EPZ Area',
  ],
  'Chattogram|Patenga': [
    'Patenga', 'Katgar', 'Steel Mill Bazar', 'Airport Road (Ctg)',
  ],
  'Chattogram|Bakalia': [
    'Bakalia', 'Chawkbazar (Ctg)', 'Rahattarpool', 'Miah Khan Nagar',
  ],
  'Chattogram|Akbarshah': [
    'Akbarshah', 'City Gate', 'Firozshah Colony', 'Biswa Colony',
  ],
  // ---------------- COX'S BAZAR ----------------
  'Cox\'s Bazar|Cox\'s Bazar Sadar': [
    'Kolatoli', 'Jhilongja', 'Baharchhara', 'Tekpara', 'Laldighir Par',
  ],
  // ---------------- CUMILLA ----------------
  'Cumilla|Cumilla Adarsha Sadar': [
    'Kandirpar', 'Jhautola (Cumilla)', 'Racecourse', 'Bagichagaon',
    'Chawkbazar (Cumilla)',
  ],
  // ---------------- SYLHET CITY (SMP) ----------------
  'Sylhet|Sylhet Kotwali': [
    'Zindabazar', 'Bandarbazar', 'Chowhatta', 'Lamabazar', 'Taltala (Sylhet)',
  ],
  'Sylhet|Airport (Sylhet)': [
    'Ambarkhana', 'Chowkidekhi', 'Khadimnagar', 'Airport Road (Sylhet)',
  ],
  'Sylhet|Shahporan': [
    'Shahporan', 'Uposhohor (Sylhet)', 'Tilagor', 'Shibganj (Sylhet)',
  ],
  'Sylhet|Dakshin Surma': [
    'Dakshin Surma', 'Kadamtali (Sylhet)', 'Humayun Rashid Chattar',
  ],
  'Sylhet|Jalalabad': [
    'Jalalabad', 'Pathantula', 'Subid Bazar', 'Akhalia',
  ],
  'Sylhet|Moglabazar': [
    'Moglabazar', 'Shibbari', 'Alampur',
  ],
  // ---------------- RAJSHAHI CITY (RMP) ----------------
  'Rajshahi|Boalia': [
    'Shaheb Bazar', 'Alupatti', 'Ranibazar', 'Sagorpara', 'Terokhadia',
  ],
  'Rajshahi|Motihar': [
    'Kazla', 'Binodpur', 'Talaimari', 'Dharampur',
  ],
  'Rajshahi|Rajpara': [
    'Uposhohor (Rajshahi)', 'Laxmipur', 'Court Area', 'Horogram',
  ],
  'Rajshahi|Shah Makhdum': [
    'Naodapara', 'Airport Road (Rajshahi)', 'Baya',
  ],
  // ---------------- KHULNA CITY (KMP) ----------------
  'Khulna|Khulna Sadar': [
    'Royal Mor', 'Shantidham Mor', 'PTI Mor', 'Dakbangla', 'Ferry Ghat',
  ],
  'Khulna|Sonadanga': [
    'Sonadanga R/A', 'Nirala', 'Gollamari', 'Boyra',
  ],
  'Khulna|Khalishpur': [
    'Khalishpur', 'Housing Estate (Khulna)', 'Goalkhali', 'BIDC Road',
  ],
  'Khulna|Daulatpur': [
    'Daulatpur Bazar', 'Pabla', 'Muhsin Mor', 'Railgate (Daulatpur)',
  ],
  // ---------------- BARISHAL CITY ----------------
  'Barishal|Kotwali (Barishal)': [
    'Sadar Road', 'Nathullabad', 'Chowmatha', 'Bogura Road', 'Alekanda',
  ],
  'Barishal|Bandar (Barishal)': [
    'Port Road', 'Launch Ghat Area', 'Dapdapia',
  ],
  // ---------------- RANGPUR CITY ----------------
  'Rangpur|Rangpur Kotwali': [
    'Jahaj Company Mor', 'Dhap', 'Station Road (Rangpur)', 'Modern Mor',
    'Lalbag (Rangpur)',
  ],
  // ---------------- MYMENSINGH CITY ----------------
  'Mymensingh|Mymensingh Sadar': [
    'Ganginar Par', 'Choto Bazar', 'Town Hall Mor', 'Charpara', 'Kachari',
  ],
  // ---------------- BOGURA ----------------
  'Bogura|Bogura Sadar': [
    'Satmatha', 'Jaleshwaritola', 'Sherpur Road (Bogura)', 'Khandar',
  ],
  // ---------------- JASHORE ----------------
  'Jashore|Jashore Sadar': [
    'Dhormotola', 'MK Road', 'Chitra Mor', 'New Market (Jashore)',
  ],
  // ---------------- DINAJPUR ----------------
  'Dinajpur|Dinajpur Sadar': [
    'Bahadur Bazar', 'Munshipara', 'Balubari', 'Suihari',
  ],
  // ---------------- KUSHTIA ----------------
  'Kushtia|Kushtia Sadar': [
    'NS Road', 'Mojompur', 'Courtpara', 'Thanapara',
  ],
  // ---------------- PABNA ----------------
  'Pabna|Pabna Sadar': [
    'Abdul Hamid Road', 'Shalgaria', 'Radhanagar', 'Gopalpur (Pabna)',
  ],
  // ---------------- FENI ----------------
  'Feni|Feni Sadar': [
    'Trunk Road', 'SSK Road', 'Mizan Road', 'Academy Area',
  ],
  // ---------------- NOAKHALI ----------------
  'Noakhali|Noakhali Sadar': [
    'Maijdee Court', 'Maijdee Bazar', 'Datterhat', 'Sonapur (Noakhali)',
  ],
  // ---------------- BRAHMANBARIA ----------------
  'Brahmanbaria|Brahmanbaria Sadar': [
    'Kautoli', 'Court Road (B.Baria)', 'Paikpara (B.Baria)', 'Munshefpara',
  ],
  // ---------------- TANGAIL ----------------
  'Tangail|Tangail Sadar': [
    'Victoria Road', 'Niralapara', 'College Para (Tangail)', 'Adalat Para',
  ],
  // ---------------- FARIDPUR ----------------
  'Faridpur|Faridpur Sadar': [
    'Jhiltuli', 'Goalchamot', 'Alipur (Faridpur)', 'Komlapur (Faridpur)',
  ],
};

/// Convenience helpers over the dataset.
class BdLocations {
  BdLocations._();

  static List<String> get divisions => bdDivisions.keys.toList();

  static List<String> districtsOf(String division) =>
      bdDivisions[division]?.keys.toList() ?? [];

  static List<String> thanasOf(String division, String district) =>
      bdDivisions[division]?[district] ?? [];

  /// Curated areas when available, otherwise an honest sadar/bazar fallback.
  static List<String> areasForThana(String district, String thana) {
    final curated = bdThanaAreas['$district|$thana'];
    if (curated != null) return curated;
    // Strip an existing "Sadar" suffix to avoid "X Sadar Sadar".
    final base = thana.replaceAll(' Sadar', '');
    return ['$base Sadar', '$base Bazar', 'College Road ($base)'];
  }
}
