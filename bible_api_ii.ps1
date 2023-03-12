

# CONSTANTES

$scrapy_date = Get-Date -Format "yyyy-MM-dd"
$scrapy_storange_path = "C:\scrapy\bible_api_request"

$base_url = "https://api.scripture.api.bible/v1"

$h = @{"api-key"="5679c91f89b7c5dfc4064513b1681d7a"}

$pt_bible_id = "d63894c8d9a7a503-01"



# GET BIBLE NAME
$pt_bible_id_request = $base_url + "/bibles/" + $pt_bible_id

$r = Invoke-WebRequest -Uri $pt_bible_id_request -Headers $h -UseBasicParsing

$bible_info = $($r.Content | Out-String | ConvertFrom-Json).data

$bible_name = $bible_info.nameLocal.ToLower().trim().replace(' ', '_')


# VERIFY SCRAPY FOLDERS
$storange_current_path = $scrapy_storange_path + "\" + $scrapy_date + "\" + $bible_name

if (-not(Test-path $storange_current_path)) {
    echo "Creating '$scrapy_date' Path"
    echo ""

    mkdir $storange_current_path
} 
else {
    echo "Deleting and Creating '$scrapy_date' Path"
    echo ""

    rmdir -r $storange_current_path
    mkdir $storange_current_path
}



# GET ALL BOOKS FROM BR BIBLE
$bible_books_request_url = $base_url + "/bibles/" + $pt_bible_id + "/books"

$r = Invoke-WebRequest -Uri $bible_books_request_url -Headers $h -UseBasicParsing

$book_list = $($r.Content | Out-String | ConvertFrom-Json).data


foreach ($book in $book_list) {
    $book_id = $book.id
    $book_name = $book.name


    $storange_book_path = $storange_current_path + "\" + $book_name

    if (-not(Test-path $storange_book_path)) {
        mkdir $storange_book_path
    }


    $book_chapters_request_url = $base_url + "/bibles/" + $pt_bible_id + "/books/" + $book_id + "/chapters"

    $r = Invoke-WebRequest -Uri $book_chapters_request_url -Headers $h -UseBasicParsing
    
    $chapter_list =  $($r.Content | Out-String | ConvertFrom-Json).data
    
    $chapter_id_list = $chapter_list | ForEach-Object { $_.id }




    # GET BI,BLE BOOK CHAPTER CONTENTS
    foreach ($chapter_id in $chapter_id_list) {
        
        $storange_chapter_path = $storange_book_path + "\" + $($chapter_id.ToLower().trim().replace('.', '_'))

        $chapter_content_request_url = $base_url + "/bibles/" + $pt_bible_id + "/chapters/" + $chapter_id
        
        $r = Invoke-WebRequest -Uri $chapter_content_request_url -Headers $h -UseBasicParsing
        
        $chapter_content = $($r.Content | Out-String | ConvertFrom-Json).data

        Add-Content -Path $storange_chapter_path -Value $chapter_content.content
        
    }


}


