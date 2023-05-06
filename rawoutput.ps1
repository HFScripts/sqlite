# Read the contents of the output.txt file 
$content = Get-Content .\output.txt -Raw 

# Define regex patterns for email addresses, street addresses, phone numbers, and names 
$email_pattern = '\b[A-Za-z0-9._+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}\b' 
$address_pattern = '\d+\s+([A-Za-z]+\s+){1,3}(Street|Road|Avenue|St\.|Rd\.|Ave\.)' 
$phone_pattern = '027\d{7}\b' 
$name_pattern = '[A-Za-z]+\s[A-Za-z]+$' 

# Find matches for each pattern and output the results 
$email_matches = Select-String -InputObject $content -Pattern $email_pattern -AllMatches | Foreach-Object {$_.Matches.Value.ToLower()} | Select-Object -Unique
$address_matches = Select-String -InputObject $content -Pattern $address_pattern -AllMatches | Foreach-Object {$_.Matches.Value.ToLower()} | Select-Object -Unique
$phone_matches = Select-String -InputObject $content -Pattern $phone_pattern -AllMatches | Foreach-Object {$_.Matches.Value} | Select-Object -Unique
$name_matches = Select-String -InputObject $content -Pattern $name_pattern -AllMatches | Foreach-Object {$_.Matches.Value.ToLower()} | Select-Object -Unique

# Print out the matches
Write-Host "Email matches:"
$email_matches | Write-Output

Write-Host "`nAddress matches:"
$address_matches | Write-Output

Write-Host "`nPhone matches:"
$phone_matches | Write-Output

Write-Host "`nName matches:"
$name_matches | Write-Output
