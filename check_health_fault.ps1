##########################################################################
#
# NAME: 	check_health_fault.ps1
#
# AUTHOR: 	Wayne Eveland at Cutting Edge Computers
# EMAIL: 	wayne.eveland@cecpower.net
#
# COMMENT:  Check Cluster Health Fault for NSClient++/NRPE
#
# CREDITS:  
#
#			Return Values for NRPE:
#			Everything OK - OK (0)
#			Failed - FAILED (2)
#
# CHANGELOG: v0.01 Initial Commit
# 
#
##########################################################################


$NagiosStatus = "0"
$NagiosDescription = ""
$NagiosReturn = ""
$Faults = ""
try {
    $Faults = Get-HealthFault
    }
catch {
    Write-Host "FAILED: Unable to execute Get-HealthFault"
    exit 2
    }

if ( $null -ne $Faults) {
        Foreach ($Fault in $Faults) {
            Switch -Wildcard ($Fault.PerceivedSeverity) {
            "Minor*" { 
                if ($NagiosStatus -lt 1) {
                    $NagiosStatus = 1
                    $NagiosReturn = "WARNING:"
                    }
                break }
            "Major*" { 
                if ($NagiosStatus -lt 2) {
                    $NagiosStatus = 2
                    $NagiosReturn = "CRITICAL:"
                    }
                break }
             Default  {  
                if ($NagiosStatus -lt 2) {
                    $NagiosStatus = 2
                    $NagiosReturn = "CRITICAL:"
                    }
                break }
            }
       
            #Add Fault Type to Description
            $NagiosDescription = $NagiosDescription + " (Type: " + $Fault.FaultType

            #Add Fault Reason to Description
            $NagiosDescription = $NagiosDescription + " Reason: " + $Fault.Reason

            #Add REcommendation to Description
            $NagiosDescription = $NagiosDescription + " RecAction: " + $Fault.RecommendedAction

            #close off description
            $NagiosDescription = $NagiosDescription + ")"
        }
    }
else{
    $NagiosDescription = "OK: No health faults found"
    }

Write-Host "$NagiosReturn $NagiosDescription"
exit $NagiosStatus

