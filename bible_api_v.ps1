
# -------------- FUNÇOES --------------

function get_credentials {
    param($credentials_path)

    try {
        $content = $(Get-Content $credentials_path).split("=")
        $h = @{$content[0]=$content[-1]}

        return $h

    } catch {
        return $false
        
    }

}


function verify_existing_bible_id {
    param(
        $h,
        $base_url, 
        $pt_bible_id, 
        $bible_name_pt
    )

    $url = $base_url + "/bibles/" + $pt_bible_id
    
    try {       
        $r = Invoke-WebRequest -Uri $url -Headers $h -UseBasicParsing

        $bible = $($r.Content | Out-String | ConvertFrom-Json).data

        $pt_bible_id = $bible.id
        $bible_name = $bible.nameLocal.ToLower().trim().replace(' ', '_')

        return $pt_bible_id, $bible_name


    } catch {
        $url = $base_url + "/bibles"
    
        $r = Invoke-WebRequest -Uri $url -Headers $h -UseBasicParsing
    
        $all_available_bible_list = $($r.Content | Out-String | ConvertFrom-Json).data

        foreach ($bible in $all_available_bible_list) {
            if ($bible.language.id.tolower().trim() -eq "por") {

                if ($bible.name.ToLower().trim().replace(' ', '_') -eq $bible_name_pt) {
                    $pt_bible_id = $bible.id
                    $bible_name = $bible.nameLocal.ToLower().trim().replace(' ', '_')

                    return $pt_bible_id, $bible_name
            
                }
        
            }
    
        }
    }
    # IF TRY AND CATCH ERROR, RETURN HERE
}

function get_chapter_content {
    param(
        $h,
        $base_url, 
        $chapter_id,
        $pt_bible_id
    )

    $chapter_content_request_url = $base_url + "/bibles/" + $pt_bible_id + "/chapters/" + $chapter_id
        
    $r = Invoke-WebRequest -Uri $chapter_content_request_url -Headers $h -UseBasicParsing
        
    $chapter_content = $($r.Content | Out-String | ConvertFrom-Json).data

    return $chapter_content.content

}

function get_all_books {
    param(
        $h,
        $base_url, 
        $pt_bible_id
    )

    $bible_books_request_url = $base_url + "/bibles/" + $pt_bible_id + "/books"

    $r = Invoke-WebRequest -Uri $bible_books_request_url -Headers $h -UseBasicParsing

    $book_list = $($r.Content | Out-String | ConvertFrom-Json).data

    return $book_list

}

function verify_bible_table {
    param(
        $bible_name,
        $connection
    )

    $tables = Invoke-SqliteQuery -Query """select name from sqlite_master where type='table'""".replace('"', '') `                                 -SQLiteConnection $connection

    if (-not($bible_name -in $tables.name)) {
        $query_create_table = """
        create table $bible_name (
	        book_name       TEXT,
	        chapter_name    TEXT,
	        chapter_content TEXT,
	        process_date    TEXT
        );
        """.replace('"', '')

        Invoke-SqliteQuery -Query $query_create_table -SQLiteConnection $connection
    }
}


function delete_current_data {
    param(
        $scrapy_date,
        $connection
    )

    $max_process_table_date = Invoke-SqliteQuery -Query """select max(process_date) max_date from $bible_name""".replace('"', '') `                                                 -SQLiteConnection $connection

    if ($scrapy_date -eq $([string]$max_process_table_date.max_date)) {
        $query_delete = """
        delete from $bible_name 
        where process_date = '$scrapy_date'
        """.replace('"', '')

        Invoke-SqliteQuery -Query $query_delete -SQLiteConnection $connection
    }

}



# -------------- CONSTANTES -------------- 



$scrapy_date = Get-Date -Format "yyyy-MM-dd"
$scrapy_storange_path = "C:\scrapy\bible_api_request"
$scrapy_storange_log_path = $scrapy_storange_path + "\logs.txt"

$pt_bible_id = "d63894c8d9a7a503-01"
$bible_name_pt = "biblia_livre_para_todos"
$base_url = "https://api.scripture.api.bible/v1"

$database_path = ".\the_bible.sqlite"


#  -------------- MAIN  -------------- 



Add-Content -Path $scrapy_storange_log_path `
            -Value "$(Get-Date -Format "yyyy-MM-dd HH:mm:ss") | [INFO] | API REQUEST STARTED"


$h = get_credentials -credentials_path "C:\Users\gabri\scripts_powershell\parte_2\ps1\the_bible_api\utils\config.env"

if (-not $h) {
    Add-Content -Path $scrapy_storange_log_path `
                -Value "$(Get-Date -Format "yyyy-MM-dd HH:mm:ss") | [ERROR] | INVALID CREDENTIALS PATH"

    Add-Content -Path $scrapy_storange_log_path -Value ""
    Add-Content -Path $scrapy_storange_log_path -Value $Error[0..1]
    Add-Content -Path $scrapy_storange_log_path -Value ""

    exit 

}

# VERIFY PT BIBLE
$pt_bible_id, $bible_name = verify_existing_bible_id -h $h -base_url $base_url `
                                                     -pt_bible_id $pt_bible_id  -bible_name_pt $bible_name_pt


# GET ALL BOOKS FROM BR BIBLE
Add-Content -Path $scrapy_storange_log_path `
            -Value "$(Get-Date -Format "yyyy-MM-dd HH:mm:ss") | [INFO] | START ALL BOOKS REQUEST" 



$book_list = get_all_books -h $h -base_url $base_url -pt_bible_id $pt_bible_id

$connection = New-SqliteConnection -DataSource $database_path

verify_bible_table -bible_name $bible_name -connection $connection

delete_current_data -scrapy_date $scrapy_date -connection $connection

foreach ($book in $book_list) {
    $book_id = $book.id
    $book_name = $book.name


    $storange_book_path = $storange_current_path + "\" + $book_name

    $book_chapters_request_url = $base_url + "/bibles/" + $pt_bible_id + "/books/" + $book_id + "/chapters"

    $r = Invoke-WebRequest -Uri $book_chapters_request_url -Headers $h -UseBasicParsing
    
    $chapter_list =  $($r.Content | Out-String | ConvertFrom-Json).data
    
    $chapter_id_list = $chapter_list | ForEach-Object { $_.id }

    Add-Content -Path $scrapy_storange_log_path `
                -Value "$(Get-Date -Format "yyyy-MM-dd HH:mm:ss") | [INFO] | START COLLECT FOR BOOK: $book_name" 


    # GET BIBLE BOOK CHAPTER CONTENTS
    foreach ($chapter_id in $chapter_id_list) {
        $chapter_current_name = $chapter_id.ToLower().trim().replace('.', '_')

        $storange_chapter_path = $storange_book_path + "\" + $chapter_current_name + ".txt"

        $chapter_content = get_chapter_content -h $h -base_url $base_url `
                                               -chapter_id $chapter_id -pt_bible_id $pt_bible_id
        
        $chapter_content = $chapter_content.replace("'", '"')
        
        $query_insert = """
        insert into $bible_name (book_name,chapter_name,chapter_content,process_date)
        values ('$book_name', '$chapter_current_name', '$chapter_content', '$scrapy_date')

        """.replace('"', '')
        
        Invoke-SqliteQuery -Query $query_insert -SQLiteConnection $connection

        
    }

}


Add-Content -Path $scrapy_storange_log_path `
            -Value "$(Get-Date -Format "yyyy-MM-dd HH:mm:ss") | [INFO] | API REQUEST ENDED"

Add-Content -Path $scrapy_storange_log_path -Value ""