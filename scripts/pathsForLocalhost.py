import glob

collection = "/Users/dried/Repositories/JRA/portal-app/**/*.*"
old = 'href="https://portal.raff-archiv.ch'
new = 'href="http://localhost:8080/exist/apps/raffArchive'



for allfiles in glob.glob('*.*'):

for inputFile in allfiles: # Ich glaube das funktioniert so noch nicht, suche noch die Lösung dazu
	with open(inputFile, 'w') as file :
	  filedata = file.read() # Daten aus Datei in variable lesen
	  replacement = filedata.replace(old, new) # String korrigieren
	  file.write(replacement) # Korrigierten String in die Datei schreiben