all: convert extract

convert:
	for i in *.xlsx; do xlsxtotei $$i `basename $$i .xlsx`.xml;done

extract:
	saxon -it:main aiis.xsl prefix=ARCH
	/Users/rahtz/TEI/apache-jena-2.11.1/bin/rdfcat -out n3 aiis.rdf  > aiis.n3
	trang aiis.rng aiis.xsd
