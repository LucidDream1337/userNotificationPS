#Initialisierung/Variablen
## Initialisierung benötigter Komponenten
[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Drawing")
[void] [System.Reflection.Assembly]::LoadWithPartialName("Microsoft.VisualBasic") 
Add-Type -AssemblyName System.Windows.Forms
Add-Type @'
using System.Windows.Forms;
public class FormWithoutX : Form {
  protected override CreateParams CreateParams
  {
    get {
      CreateParams cp = base.CreateParams;
      cp.ClassStyle = cp.ClassStyle | 0x200;
      return cp;
    }
  }

}
'@ -ReferencedAssemblies System.Windows.Forms
[System.Windows.Forms.Application]::EnableVisualStyles()

## Variablen
$objForm = [FormWithoutX]::new()
$pictureBox = New-Object System.Windows.Forms.PictureBox
$informationLabel = New-Object System.Windows.Forms.LinkLabel

$imageRAW = (Get-Item "$($PSScriptRoot)\res\UTN-Website-icon-250.png")
$image = [System.Drawing.Image]::FromFile($imageRAW)

#Design
##Form
$objForm.StartPosition = "CenterScreen"
$objForm.FormBorderStyle = "FixedDialog"
$objForm.MaximizeBox = $false
$objForm.Size = New-Object System.Drawing.Size(750,310)

##Picturebox
$pictureBox.Size = $image.Size
$pictureBox.Location = New-Object System.Drawing.Size(10,10)

##Label
$informationLabel.Padding = 10
$informationLabel.Size = New-Object System.Drawing.Size(500,250)
$informationLabel.Location = New-Object System.Drawing.Size(270,40)

#-------------------------------#

#Content
##Form
$objForm.Text = "Information an den Benutzer"

##Picturebox
$pictureBox.Image = $image

##Label
$informationLabel.Font = New-Object System.Drawing.Font("Arial",12)
$informationLabel.Text = "Die Installation von Windows 11 wurde gestartet.`nBitte sichern Sie Ihre Arbeit und lassen Sie uns alles weitere machen.`n`nDer Computer startet in wenigen Minuten neu`n`n`nBei Fragen: it-service@utn.de"
$informationLabel.LinkArea = New-Object System.Windows.Forms.LinkArea(179,195)
$informationLabel.add_LinkClicked({
  Start-Process "mailto:it-service@utn.de"
})

#-------------------------------#
#Stick together
$objForm.Controls.Add($pictureBox)
$objForm.Controls.Add($informationLabel)

#Activate
$objForm.ShowDialog()