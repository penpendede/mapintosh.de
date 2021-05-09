<?php
$pageSetup = [
    'screenshotPath' => 'images/screenshots/',
    'thumbnailPath' => 'images/thumbnails/',
    'content' => [
        [
            'title' => 'Online Maps',
            'description' => [
                '<p>',
                'Some online maps I created',
                '</p>'
            ],
            'tableId' => 'webmaps',
            'tableContent' => [
                [
                    'map' => [
                        'path' => 'BN-districts',
                        'title' => 'Districts of Bonn'
                    ],
                    'modified' => '2020-05-30',
                    'created' => '2020-05-29',
                    'description' => [
                        'city districts limits are taken from <a href="https=>//opendata.bonn.de">opendata.bonn.de</a> and then processed by a ',
                        '<a href="https=>//github.com/penpendede/mapintosh.de/blob/master/BN-districts/getDistricts.sh">tiny shell script</a> you may find interesting.'
                    ],
                    'screenshot'=> 'BN-districts.jpg',
                    'thumbnail'=> 'BN-districts.jpg',
                    'changes' => [
                        'selected districts are shown in color, everything else is dimmed out'
                    ]
                ],
                [
                    'map' => [
                        'path' => 'airportWeather/website',
                        'title' => 'METAR (weather) data for airports'
                    ],
                    'modified' => '2020-09-12',
                    'created' => '2020-09-13',
                    'description' => [
                        'provides access to wether information for  airports worldwide. The source of this project is available at ',
                        '<a href="https=>//github.com/penpendede/airportWeather" target="_blank">github.com/penpendede/airportWeather</a>'
                    ],
                    'screenshot'=> 'airportWeather.jpg',
                    'thumbnail'=> 'airportWeather.jpg',
                    'changes' => [
                        'now using a git submodule for airportWeather'
                    ]
                ],
                [
                    'map' => [
                        'path' => 'myOsm',
                        'title' => 'OSM Map of Bonn'
                    ],
                    'modified' => '2020-05-29',
                    'created' => '2020-05-24',
                    'description' => [
                        'accompanies ',
                        '<a href="http=>//penpende.de/doku.php?id=installation_guides=>tileserver_on_raspberry_pi_4" target="_blank">Installing a tile server on a Raspberry Pi 4</a>'
                    ],
                    'screenshot'=> 'myOsm.jpg',
                    'thumbnail'=> 'myOsm.jpg',
                    'changes' => [
                        'use minimized files',
                        'local, pre-rendered tiles',
                        'added grayscale rendering',
                        'maximize button'
                    ]
                ],
                [
                    'map' => [
                        'path' => 'Porto',
                        'title' => 'Porto'
                    ],
                    'modified' => '2020-05-29',
                    'created' => '2020-05-24',
                    'description' => [
                        'accompanies <a href="http=>//penpende.de/doku.php?id=gis=>making_use_of_openstreetmap" target="_blank">Making use of OpenStreetMap</a>'
                    ],
                    'screenshot'=> 'Porto.jpg',
                    'thumbnail'=> 'Porto.jpg',
                    'changes' => [
                        '<ul>',
                        '<li>use minimized files</li>',
                        '<li>added grayscale rendering</li>',
                        '<li>maximize button</li>',
                        '<li>instead of showing all kinds of POI you can now select it using the layer selector in the upper right corner.</li>',
                        '</ul>'
                    ]
                ],
                [
                    'map' => [
                        'path' => 'BN-recycling',
                        'title' => 'Recycling in Bonn'
                    ],
                    'modified' => '2020-06-02',
                    'created' => '2020-06-02',
                    'description' => [
                        'Part of getData.js deals with fixing issues with the original data. Once they are fixed the original script will remain available as it ',
                        'illustrates how command-line tools can be used to fix certain issues with GeoJSON files.'
                    ],
                    'screenshot'=> 'BN-recycling.jpg',
                    'thumbnail'=> 'BN-recycling.jpg',
                    'changes' => [
                        '-'
                    ]
                ],
                [
                    'map' => [
                        'path' => 'stolpersteine',
                        'title' => 'all stolpersteins from the OSM database'
                    ],
                    'modified' => '2020-11-15',
                    'created' => '2020-11-10',
                    'description' => [
                        'an overview of the thousands of stolperteins that have already been added to the OSM database'
                    ],
                    'screenshot'=> 'stolpersteine.jpg',
                    'thumbnail'=> 'stolpersteine.jpg',
                    'changes' => [
                        'Using tab separated values instead of geoJSON, considerably reducing the amount of data that needs to be transferred.'
                    ]
                ],
                [
                    'map' => [
                        'path' => 'BN-tree',
                        'title' => 'Trees in Bonn'
                    ],
                    'modified' => '2020-05-31',
                    'created' => '2020-05-31',
                    'description' => [
                        'Visualizes trees in public space (streets, parks) within the city limits of Bonn and provides the species as well as the age (open data, ',
                        'over 60k entries). It also shows how you can visualize such a huge dataset and still have Leaflet render it very rapidly. It uses open data ',
                        'from  <a href="https=>//opendata.bonn.de/dataset/baumstandorte" target="_blank">https=>//opendata.bonn.de/dataset/baumstandorte</a> released ',
                        'under CC0'
                    ],
                    'screenshot'=> 'BN-tree.jpg',
                    'thumbnail'=> 'BN-tree.jpg',
                    'changes' => [
                        '-'
                    ]
                ]
            ]
        ],
        [
            'title' => 'Maps with QGIS',
            'description' => [
                '<p>',
                '<a href="https=>//www.qgis.org/" target="_blank">QGIS</a> is a free and open source geographic information system for the desktop that is available for ',
                'many platforms.',
                '</p>'
            ],
            'tableId' => 'qgismaps',
            'tableContent' => [
                [
                    'map' => [
                        'path' => null,
                        'title' => 'Stolpersteine in Bonn'
                    ],
                    'modified' => '2020-06-10',
                    'created' => '2020-06-10',
                    'description' => [
                        '<p>',
                        'A QGIS project that has all stolpersteine in Bonn. The GeoPackage file was generated using QGIS and a cute plugin that queries the OSM database. ',
                        'Description how to generated it will follow. For now you can',
                        '</p>',
                        '<ul>',
                        '<li>',
                        '<a href="QGIS/Stolpersteine_in_Bonn/Stolpersteine_in_Bonn.qgs" target="_blank">Get the qgis project</a> (data is loaded from this server)',
                        '</li>',
                        '<li>',
                        '<a href="QGIS/Stolpersteine_in_Bonn/Stolpersteine_in_Bonn_Data.zip" target="_blank">Get a ZIP</a> that contains all files used (including the',
                        'QGIS project)</li>',
                        '</ul>',
                        '<p>',
                        'You don\'t already have QGIS? No problem, it is available for most platforms at <a href="https=>//www.qgis.org/" target="_blank">qgis.org</a>.',
                        '</p>'
                    ],
                    'screenshot'=> '',
                    'thumbnail' => '',
                    'changes' => [
                        '-'
                    ]
                ]
            ]
        ]
    ]
];
