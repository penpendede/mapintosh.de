
<?php
require __DIR__ . '/vendor/autoload.php';
include 'pageSetup.php';

use Twig\Environment;
use Twig\Loader\FilesystemLoader;

$loader = new FilesystemLoader(__DIR__ . '/templates');
$twig = new Environment($loader);

$sections = [];
foreach ($pageSetup as $section) {
    $rows = [];
    foreach ($section['tableContent'] as $row) {
        array_push($rows, $twig->render('index-section-table-row.html.twig', [
            "linkTarget" => $row['map']['path'],
            "title" => $row['map']['title'],
            "modified" => $row['modified'],
            "created" => $row['created'],
            "description" => implode($row['description']),
            "changes" => implode($row['changes'])
        ]));
    }
    
    array_push($sections, $twig->render('index-section.html.twig', [
        'title' => $section['title'],
        'description' => implode($section['description']),
        'tableId' => $section['tableId'],
        'tableContent' => implode('', $rows)
    ]));
}

echo $twig->render('index.html.twig', [
    'overviewSection' => implode('', $sections)
]);