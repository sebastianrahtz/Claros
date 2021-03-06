<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns:skos="http://www.w3.org/2004/02/skos/core#"
		xmlns:claros="http://purl.org/NET/Claros/vocab#"
		xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
		xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
		xmlns:owl="http://www.w3.org/2002/07/owl#"
		xmlns:xsd="http://www.w3.org/2001/XMLSchema#"
		xmlns:crm="http://www.cidoc-crm.org/cidoc-crm"
		xmlns:xs="http://www.w3.org/2001/XMLSchema"
		xmlns:tei="http://www.tei-c.org/ns/1.0"
		xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
		xmlns:rso="http://www.researchspace.org/ontology/"
		exclude-result-prefixes="rdf rdfs crm xs tei skos owl xsd claros rso" version="2.0">
  <xsl:output method="xml" indent="yes" encoding="utf-8"/>
  <xsl:param name="prefix">*</xsl:param>

  <xsl:key name="GEO" match="place" use="name"/>
  
    <xsl:variable name="geonames">
      <places>
	<!--
	    eonameid         : integer id of record in geonames database
name              : name of geographical point (utf8) varchar(200)
asciiname         : name of geographical point in plain ascii characters, varchar(200)
alternatenames    : alternatenames, comma separated, ascii names automatically transliterated, convenience attribute from alternatename table, varchar(10000)
latitude          : latitude in decimal degrees (wgs84)
longitude         : longitude in decimal degrees (wgs84)
feature class     : see http://www.geonames.org/export/codes.html, char(1)
feature code      : see http://www.geonames.org/export/codes.html, varchar(10)
country code      : ISO-3166 2-letter country code, 2 characters
cc2               : alternate country codes, comma separated, ISO-3166 2-letter country code, 60 characters
admin1 code       : fipscode (subject to change to iso code), see exceptions below, see file admin1Codes.txt for display names of this code; varchar(20)
admin2 code       : code for the second administrative division, a county in the US, see file admin2Codes.txt; varchar(80) 
admin3 code       : code for third level administrative division, varchar(20)
admin4 code       : code for fourth level administrative division, varchar(20)
population        : bigint (8 byte int) 
elevation         : in meters, integer
dem               : digital elevation model, srtm3 or gtopo30, average elevation of 3''x3'' (ca 90mx90m) or 30''x30'' (ca 900mx900m) area in meters, integer. srtm processed by cgiar/ciat.
timezone          : the timezone id (see file timeZone.txt) varchar(40)
modification date : date of last modification in yyyy-MM-dd format
-->
      <xsl:for-each select="tokenize(unparsed-text('IN.txt'),
			    '\r?\n')">
	<xsl:variable name="row" select="tokenize(.,'\|')"/>
	<xsl:if test="starts-with($row[8],'PPL') or $row[8]='ANS' or
	  $row[8]='HSTS' or $row[8]='RUIN'">
	<place>
	  <id><xsl:value-of select="$row[1]"/></id>
	  <name><xsl:value-of select="$row[3]"/></name>
	  <altnames><xsl:value-of select="$row[3]"/></altnames>
	  <type><xsl:value-of select="$row[8]"/></type>
	  <lat><xsl:value-of select="$row[5]"/></lat>
	  <long><xsl:value-of select="$row[6]"/></long>
	</place>
	</xsl:if>
      </xsl:for-each>
      </places>
    </xsl:variable>

    <xsl:template match="/">
    <xsl:call-template name="main"/>
  </xsl:template>
  <xsl:template name="main">
    <xsl:variable name="pathlist">
      <xsl:value-of select="concat('.?select=',$prefix,'*.xml;recurse=yes;on-error=warning')"/>
    </xsl:variable>
    <xsl:variable name="docs" select="collection($pathlist)"/>
    <xsl:result-document href="IN.xml">
      <xsl:copy-of select="$geonames"/>
    </xsl:result-document>
    <xsl:variable name="aiis">
      <aiis>
        <xsl:for-each select="$docs">
          <xsl:comment>processing <xsl:value-of select="base-uri(.)"/></xsl:comment>
          <xsl:for-each select=".//tei:table[1]/tei:row[position()            &gt;1]">
            <xsl:if test="tei:cell[1] != ''">
              <record>
                <File>
                  <xsl:value-of select="substring-before(tokenize(base-uri(.),'/')[last()],'.xml')"/>
                </File>
                <xsl:for-each select="tei:cell">
                  <xsl:variable name="n" select="position()"/>
                  <xsl:variable name="l"
				select="lower-case(ancestor::tei:table/tei:row[1]/tei:cell[$n])"/>
		  <xsl:variable name="name">
		    <xsl:choose>
		      <xsl:when test="$l='monument type'">mon_type</xsl:when>
		      <xsl:when test="$l='negative no'">neg_no</xsl:when>
		      <xsl:when test="$l='neg NO'">neg_no</xsl:when>
		      <xsl:when test="$l='accession no'">acc_no</xsl:when>
		      <xsl:when test="$l='general_category'">gen_cat</xsl:when>
		      <xsl:otherwise><xsl:value-of select="translate(normalize-space($l),' /()\?','_')"/></xsl:otherwise>
		    </xsl:choose>
		  </xsl:variable>
                  <xsl:if test="normalize-space(.)!=''">		    
		      <xsl:element name="{$name}">
			<xsl:value-of select="(.)"/>
                      </xsl:element>
                  </xsl:if>
                </xsl:for-each>
              </record>
            </xsl:if>
          </xsl:for-each>
        </xsl:for-each>
      </aiis>
    </xsl:variable>
    <xsl:result-document href="aiis.all" indent="yes" encoding="utf-8">
      <xsl:copy-of select="$aiis"/>
    </xsl:result-document>
    <xsl:result-document href="aiis.rdf">
      <rdf:RDF>
        <xsl:for-each select="$aiis//record">
          <E83_Information_Carrier
	      xmlns="http://www.cidoc-crm.org/cidoc-crm/"
	      rdf:about="http://www.indiastudies.org/AIIS/photo/{acc_no}">
	    <xsl:call-template name="keywords"/>
            <xsl:variable name="date" select="if (photo_date) then
					      photo_date else 'undated'"/>
                <P108i_was_produced_by>
                  <E12_Production rdf:about="http://www.indiastudies.org/AIIS/production/{crm:idme($date)}">
                    <P4_has_time-span>
                      <E52_Time-Span rdf:about="http://www.indiastudies.org/AIIS/date/{crm:idme($date)}">
                        <rdfs:label>
                          <xsl:value-of select="$date"/>
                        </rdfs:label>
                      </E52_Time-Span>
                    </P4_has_time-span>
                  </E12_Production>
		</P108i_was_produced_by>

	    <P52_has_current_owner>
	      <E21_Actor
		  rdf:about="http://www.indiastudies.org/AIIS/actor/{crm:idme(photo_source)}">
		<P87_is_identified_by>
		  <E82_Actor_Appelation rdf:about="http://www.indiastudies.org/AIIS/actorname/{crm:idme(photo_source)}">
		    <rdfs:label>
		      <xsl:value-of select="photo_source"/>
		    </rdfs:label>
		  </E82_Actor_Appelation>
		</P87_is_identified_by>
	      </E21_Actor>	      
	    </P52_has_current_owner>
            <P138i_has_representation rdf:resource="http://dsal.uchicago.edu/images/aiis/images/large/ar_{crm:pad(acc_no)}.jpg"/>
            <xsl:if test="subject_label">
              <P70i_is_documented_in>
                <E31_Document rdf:about="http://www.indiastudies.org/AIIS/photolabel/{acc_no}">
                  <rdfs:label>
                    <xsl:value-of select="subject_label"/>
                  </rdfs:label>
                </E31_Document>
              </P70i_is_documented_in>
            </xsl:if>
            <xsl:if test="exterior__interior">
              <P2_has_type>
                <E55_Type rdf:about="http://www.indiastudies.org/AIIS/intext/{crm:idme(exterior__interior)}">
                  <rdfs:label>
                    <xsl:value-of select="exterior__interior"/>
                  </rdfs:label>
                </E55_Type>
              </P2_has_type>
            </xsl:if>
            <xsl:if test="gen_categ">
              <P2_has_type>
                <E55_Type rdf:about="http://www.indiastudies.org/AIIS/category/{crm:idme(gen_categ)}">
                  <rdfs:label>
                    <xsl:value-of select="gen_categ"/>
                  </rdfs:label>
                </E55_Type>
              </P2_has_type>
            </xsl:if>
            <xsl:if test="neg_no">
              <P1_has_identifier>
                <E42_identifier rdf:about="http://www.indiastudies.org/AIIS/neg/{neg_no}"/>
              </P1_has_identifier>
            </xsl:if>
            <P62_depicts>
	      <xsl:variable name="NAME">
		  <xsl:choose>
		    <xsl:when test="monument2nd_name=''">
		      <xsl:value-of select="complex"/>
		    </xsl:when>
		    <xsl:otherwise>
		      <xsl:value-of select="monument2nd_name"/>
		    </xsl:otherwise>
		  </xsl:choose>
	      </xsl:variable>
              <E18_Physical_Thing>
		<xsl:attribute name="rdf:about">
		  <xsl:text>http://www.indiastudies.org/AIIS/</xsl:text>
		  <xsl:choose>
		    <xsl:when test="crm:idme(monument2nd_name)=''">
		      <xsl:text>complex/</xsl:text>
		      <xsl:value-of
			  select="crm:idme(monument2nd_name)"/>
		    </xsl:when>
		    <xsl:otherwise>
		      <xsl:text>place/</xsl:text>
		      <xsl:value-of
			  select="crm:idme(monument2nd_name)">
		      </xsl:value-of>
		    </xsl:otherwise>
		  </xsl:choose>
		</xsl:attribute>
                  <P87_is_identified_by>
                      <E41_Appelation rdf:about="http://www.indiastudies.org/AIIS/title/{crm:idme($NAME)}">
                    <rdfs:label>
                      <xsl:value-of select="$NAME"/>
                    </rdfs:label>
                  </E41_Appelation>
                </P87_is_identified_by>
		<xsl:call-template name="keywords"/>
                <P87_is_identified_by>
                  <E41_Appelation rdf:about="http://www.indiastudies.org/AIIS/title/{crm:idme($NAME)}">
                    <rdfs:label>
                      <xsl:value-of select="$NAME"/>
                    </rdfs:label>
                  </E41_Appelation>
                </P87_is_identified_by>
                <xsl:if test="mon_type">
                  <P2_has_type>
                    <E55_Type rdf:about="http://www.indiastudies.org/AIIS/type/{crm:idme(mon_type)}">
                      <rdfs:label>
                        <xsl:value-of select="mon_type"/>
                      </rdfs:label>
                    </E55_Type>
                  </P2_has_type>
                </xsl:if>
		<xsl:if test="style">
                  <P2_has_type>
                  <E55_Type rdf:about="http://www.indiastudies.org/AIIS/style/{crm:idme(style)}">
                    <rdfs:label>
                      <xsl:value-of select="style"/>
                    </rdfs:label>
                  </E55_Type>
                  </P2_has_type>
		</xsl:if>
                <xsl:if test="materials">
                  <P45_consists_of>
                    <E57_Material rdf:about="http://www.indiastudies.org/AIIS/material/{crm:idme(materials)}"/>
                  </P45_consists_of>
                </xsl:if>
                <P108i_was_produced_by>
                  <E12_Production rdf:about="http://www.indiastudies.org/AIIS/production/{crm:idme($NAME)}">
                    <xsl:if test="patron">
		      <P14_carried_out_by>
			<E21_Actor
			    rdf:about="http://www.indiastudies.org/AIIS/actor/{crm:idme(patron)}">
			  <P87_is_identified_by>
			    <E82_Actor_Appelation rdf:about="http://www.indiastudies.org/AIIS/actorname/{crm:idme(patron)}">
			      <rdfs:label>
				<xsl:value-of select="patron"/>
			      </rdfs:label>
			    </E82_Actor_Appelation>
			  </P87_is_identified_by>
			  </E21_Actor>
		      </P14_carried_out_by>
		    </xsl:if>
		    <xsl:if test="period">
		    <P10_falls_within>
                      <E4_period rdf:about="http://www.indiastudies.org/AIIS/period/{crm:idme(period)}">
                        <rdfs:label>
                          <xsl:value-of select="period"/>
                        </rdfs:label>
                      </E4_period>
                    </P10_falls_within>
		    </xsl:if>
                    <xsl:if test="ce_date_insc_date">
                      <P4_has_time-span>
                        <E52_Time-Span rdf:about="http://www.indiastudies.org/AIIS/date/{crm:idme(ce_date_insc_date)}">
                          <xsl:variable name="date" select="ce_date_insc_date"/>
                          <rdfs:label>
                            <xsl:value-of select="$date"/>
                          </rdfs:label>
                          <!--
			  <xsl:choose>
			    <xsl:when test="contains($date,'-')">
			      <P79_beginning_is_qualified_by>
				<E62_String>
				  <rdfs:label><xsl:value-of select="substring-before($date,'-')"/></rdfs:label>
				</E62_String>
			      </P79_beginning_is_qualified_by>
			      <P80_end_is_qualified_by>
				<E62_String>
				  <rdfs:label><xsl:value-of select="substring-after($date,'-')"/></rdfs:label>
				</E62_String>
			      </P80_end_is_qualified_by>
			    </xsl:when>
			    <xsl:otherwise>
			      <P82_at_some_time_with>
				<E62_String>
				  <rdfs:label><xsl:value-of select="$date"/></rdfs:label>
				</E62_String>
			      </P82_at_some_time_with>
			    </xsl:otherwise>
			    </xsl:choose>
				  -->
                        </E52_Time-Span>
                      </P4_has_time-span>
                    </xsl:if>
                  </E12_Production>
		</P108i_was_produced_by>
                <P53_has_former_or_current_location>
                  <E53_Place rdf:about="http://www.indiastudies.org/AIIS/monument/{crm:idme($NAME)}">
                    <P87_is_identified_by>
                      <E44_Place_Appelation rdf:about="http://www.indiastudies.org/AIIS/placename/{crm:idme($NAME)}">
                        <rdfs:label>
                          <xsl:value-of select="$NAME"/>
                        </rdfs:label>
                      </E44_Place_Appelation>
                    </P87_is_identified_by>
                    <xsl:choose>
                      <xsl:when test="monument2nd_name and complex">
                        <P89_falls_within>
                          <E53_Place rdf:about="http://www.indiastudies.org/AIIS/complex/{crm:idme(complex)}">
                            <P87_is_identified_by>
                              <E44_Place_Appelation rdf:about="http://www.indiastudies.org/AIIS/placename/{crm:idme(complex)}">
                                <rdfs:label>
                                  <xsl:value-of select="complex"/>
                                </rdfs:label>
                              </E44_Place_Appelation>
                            </P87_is_identified_by>
			    <xsl:call-template name="site"/>
                          </E53_Place>
                        </P89_falls_within>
                      </xsl:when>
                      <xsl:otherwise>
			<xsl:call-template name="site"/>
                      </xsl:otherwise>
                    </xsl:choose>
                  </E53_Place>
                </P53_has_former_or_current_location>
              </E18_Physical_Thing>
            </P62_depicts>
          </E83_Information_Carrier>
        </xsl:for-each>
      </rdf:RDF>
    </xsl:result-document>
    <xsl:result-document href="aiis.rng">
      <grammar xmlns:its="http://www.w3.org/2005/11/its" xmlns="http://relaxng.org/ns/structure/1.0" ns="" datatypeLibrary="http://www.w3.org/2001/XMLSchema-datatypes">
        <define name="aiis">
          <element name="aiis">
            <oneOrMore>
              <choice>
                <ref name="record"/>
              </choice>
            </oneOrMore>
          </element>
        </define>
        <define name="record">
          <element name="record">
            <oneOrMore>
              <choice>
                <xsl:for-each select="distinct-values($aiis//record/*/name())">
                  <xsl:sort select="."/>
                  <ref name="{.}"/>
                </xsl:for-each>
              </choice>
            </oneOrMore>
          </element>
        </define>
        <xsl:for-each select="distinct-values($aiis//record/*/name())">
          <xsl:sort select="."/>
          <define name="{.}">
            <element name="{.}">
              <text/>
            </element>
          </define>
        </xsl:for-each>
        <start>
          <ref name="aiis"/>
        </start>
      </grammar>
    </xsl:result-document>
  </xsl:template>
  <xsl:function name="crm:idme">
    <xsl:param name="c">
    </xsl:param>
    <xsl:value-of select="lower-case(replace($c,'[^\w]',''))"/>
  </xsl:function>
  <xsl:function name="crm:pad">
    <xsl:param name="c">
    </xsl:param>
    <xsl:value-of select="format-number($c,'000000')"/>
  </xsl:function>
  <xsl:template name="districtstatecountry">
    <P89_falls_within xmlns="http://www.cidoc-crm.org/cidoc-crm/" >
      <E53_Place rdf:about="http://www.indiastudies.org/AIIS/district/{crm:idme(district_taluk)}">
        <P87_is_identified_by>
          <E44_Place_Appelation rdf:about="http://www.indiastudies.org/AIIS/placename/{crm:idme(district_taluk)}">
            <rdfs:label>
              <xsl:value-of select="district_taluk"/>
            </rdfs:label>
          </E44_Place_Appelation>
        </P87_is_identified_by>
        <P89_falls_within>
          <E53_Place rdf:about="http://www.indiastudies.org/AIIS/state/{crm:idme(state)}">
            <P87_is_identified_by>
              <E44_Place_Appelation rdf:about="http://www.indiastudies.org/AIIS/placename/{crm:idme(state)}">
                <rdfs:label>
                  <xsl:value-of select="state"/>
                </rdfs:label>
              </E44_Place_Appelation>
            </P87_is_identified_by>
            <P89_falls_within>
              <E53_Place rdf:about="http://www.indiastudies.org/AIIS/country/{crm:idme(country)}">
                <P87_is_identified_by>
                  <E44_Place_Appelation rdf:about="http://www.indiastudies.org/AIIS/placename/{crm:idme(country)}">
                    <rdfs:label>
                      <xsl:value-of select="country"/>
                    </rdfs:label>
                  </E44_Place_Appelation>
                </P87_is_identified_by>
              </E53_Place>
            </P89_falls_within>
          </E53_Place>
        </P89_falls_within>
      </E53_Place>
    </P89_falls_within>
  </xsl:template>

  <xsl:template name="site">
    <P89_falls_within xmlns="http://www.cidoc-crm.org/cidoc-crm/" >
      <xsl:variable name="site" select="site_sub-site2nd_name"/>
      <E53_Place rdf:about="http://www.indiastudies.org/AIIS/site/{crm:idme($site)}">
        <P87_is_identified_by>
          <E44_Place_Appelation rdf:about="http://www.indiastudies.org/AIIS/placename/{crm:idme($site)}">
            <rdfs:label>
              <xsl:value-of select="$site"/>
            </rdfs:label>
          </E44_Place_Appelation>
        </P87_is_identified_by>
	 <xsl:choose>
	   <xsl:when test="count($geonames/key('GEO',$site))=1">
               <P87_is_identified_by>
		 <E47_Place_Spatial_Coordinates rdf:about="http://www.indiastudies.org/AIIS/coordinates/{crm:idme($site)}">
               <claros:has_geoObject>
                 <geo:Point
		     xmlns:geo="http://www.w3.org/2003/01/geo/wgs84_pos#"
		     rdf:about="http://www.indiastudies.org/AIIS/points/{crm:idme($site)}">
                   <geo:lat><xsl:value-of select="$geonames/key('GEO',$site)/lat"/></geo:lat>
                   <geo:long><xsl:value-of select="$geonames/key('GEO',$site)/long"/></geo:long>
                 </geo:Point>
               </claros:has_geoObject>
		 </E47_Place_Spatial_Coordinates>
	       </P87_is_identified_by>
	   </xsl:when>

	   <xsl:when test="contains($site,' (') and
			   count($geonames/key('GEO',substring-before($site,' ')))=1">
	     <P89_falls_within
		 rdf:resource="http://www.indiastudies.org/AIIS/site/{crm:idme(substring-before($site,' '))}"/>
	   </xsl:when>
	   <xsl:otherwise>	       
	     <xsl:message>MISSING <xsl:value-of select="$site"/></xsl:message>
	   </xsl:otherwise>
	 </xsl:choose>

      </E53_Place>
    </P89_falls_within>
  </xsl:template>

  <xsl:template name="keywords">
    <xsl:for-each select="tokenize(subjectsearchrelatedkeyword,',')">
      <xsl:variable name="k" select="normalize-space(.)"/>
      <P128_carries xmlns="http://www.cidoc-crm.org/cidoc-crm/" >
        <E73_Information_Object rdf:about="http://www.indiastudies.org/AIIS/keyword/{crm:idme($k)}">
          <P120_is_about>
            <E55_type rdf:about="http://www.indiastudies.org/AIIS/subject/{crm:idme($k)}">
              <rdfs:label>
                <xsl:value-of select="$k"/>
              </rdfs:label>
            </E55_type>
          </P120_is_about>
        </E73_Information_Object>
      </P128_carries>
    </xsl:for-each>
  </xsl:template>
</xsl:stylesheet>
<!-- http://dsal.uchicago.edu/images/aiis/images/medium/ar_055428.jpg -->
