
collection = "/Users/dried/Repositories/JRA/portal-app/**/*.*"
old = 'href="https://portal.raff-archiv.ch'
new = 'href="http://localhost:8080/exist/apps/raffArchive'

for inputFile in glob.iglob(collection, recursive=True): # Ich glaube das funktioniert so noch nicht, suche noch die Lösung dazu
	with open(inputFile) as file :
	  s = file.read()
      s = s.replace(old, new)
      with open(filepath, "w") as file:
        file.write(s)