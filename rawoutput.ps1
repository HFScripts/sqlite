# Read the contents of the output.txt file 
$content = Get-Content .\output.txt -Raw 

# Define regex patterns for email addresses, street addresses, phone numbers, and names 
$email_pattern = '\b[A-Za-z0-9._+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}\b' 
$address_pattern = '\d+\s+([A-Za-z]+\s+){1,3}(Street|South|North|East|West|Road|Avenue|Boulevard|Ln\.|Lane|Dr\.|Drive|Cir\.|Circle|Ct\.|Court|Terr\.|Terrace|Pl\.|Place|Pkwy\.|Parkway|Way|St\.|Rd\.|Ave\.)'
$phone_pattern = '\b(?:0|2)?\d{7,10}\b'
$first_name_pattern = '(?<=firstName\|)[A-Za-z]+' # Updated first name pattern
$last_name_pattern = '(?<=lastName\|)[A-Za-z]+' # Updated last name pattern

# Find matches for each pattern and output the results 
$email_matches = Select-String -InputObject $content -Pattern $email_pattern -AllMatches | Foreach-Object {$_.Matches.Value.ToLower()} | Group-Object | Sort-Object -Descending -Property Count | Select-Object -First 10
$address_matches = Select-String -InputObject $content -Pattern $address_pattern -AllMatches | Foreach-Object {$_.Matches.Value.ToLower()} | Select-Object -Unique
$phone_matches = Select-String -InputObject $content -Pattern $phone_pattern -AllMatches | Foreach-Object {$_.Matches.Value} | Group-Object | Sort-Object -Descending -Property Count

# Find the top 5 most likely first and last names
$first_name_matches = Select-String -InputObject $content -Pattern $first_name_pattern -AllMatches | Foreach-Object {$_.Matches.Value.ToLower()} | Group-Object | Sort-Object -Descending -Property Count | Select-Object -First 5
$last_name_matches = Select-String -InputObject $content -Pattern $last_name_pattern -AllMatches | Foreach-Object {$_.Matches.Value.ToLower()} | Group-Object | Sort-Object -Descending -Property Count | Select-Object -First 5

# Print out the matches
Write-Host "Email matches:"
$email_matches | Foreach-Object {"$($_.Name)"} | Write-Output

Write-Host "`nAddress matches:"
$address_matches | Write-Output

# Find the most likely phone number and the remaining phone matches
$most_likely_phone = $phone_matches | Select-Object -First 1

Write-Host "`nMost likely phone number:"
$most_likely_phone.Name | Write-Output

# Print the top 5 most likely first and last names
Write-Host "`nTop 5 most likely first names:"
$first_name_matches | Foreach-Object {"$($_.Name)"} | Write-Output

Write-Host "`nTop 5 most likely last names:"
$last_name_matches | Foreach-Object {"$($_.Name)"} | Write-Output
