$QueueName = "your_print_queue_here"

# Get a list of installed printers
$Printers = Get-Printer

# Check if the specified print queue exists
$QueueExists = $Printers | Where-Object { $_.Name -eq $QueueName }

# Set the exit code based on the result
if ($QueueExists) {
    # The specified print queue exists (success)
    exit 0
} else {
    # The specified print queue does not exist (failure)
    exit 1
}