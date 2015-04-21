all: convert extract

convert:
	for i in *.xlsx; do xlsxtotei $$i `basename $$i .xlsx`.xml;done

extract:
	saxon -it:main agra.xsl prefix=ARCH
	/Users/rahtz/TEI/apache-jena-2.11.1/bin/rdfcat -out n3 agra.rdf  > agra.n3
	trang aiis.rng aiis.xsd
