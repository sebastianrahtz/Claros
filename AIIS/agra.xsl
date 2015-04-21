<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns:skos="http://www.w3.org/2004/02/skos/core#" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#" xmlns:owl="http://www.w3.org/2002/07/owl#" xmlns:xsd="http://www.w3.org/2001/XMLSchema#" xmlns:crm="http://www.cidoc-crm.org/cidoc-crm/" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:rso="http://www.researchspace.org/ontology/" exclude-result-prefixes="xs tei skos owl xsd rso" version="2.0">
  <xsl:output method="xml" indent="yes" encoding="utf-8"/>
  <xsl:param name="prefix">*</xsl:param>
  <xsl:template match="/">
    <xsl:call-template name="main"/>
  </xsl:template>
  <xsl:template name="main">
    <xsl:variable name="pathlist">
      <xsl:value-of select="concat('.?select=',$prefix,'*.xml;recurse=yes;on-error=warning')"/>
    </xsl:variable>
    <xsl:variable name="docs" select="collection($pathlist)"/>
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
    <xsl:result-document href="agra.all" indent="yes" encoding="utf-8">
      <xsl:copy-of select="$aiis"/>
    </xsl:result-document>
    <xsl:result-document href="agra.rdf">
      <rdf:RDF>
        <xsl:for-each select="$aiis//record">
          <E83_Information_Carrier
	      xmlns="http://www.cidoc-crm.org/cidoc-crm/"
	      rdf:about="http://www.indiastudies.org/AIIS/photo/{acc_no}">
	    <xsl:call-template name="keywords"/>
            <xsl:variable name="date" select="photo_date"/>
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
            <xsl:if test="neg_NO">
              <P1_has_identifier>
                <E42_identifier rdf:about="http://www.indiastudies.org/AIIS/neg/{neg_no}"/>
              </P1_has_identifier>
            </xsl:if>
            <P62_depicts>
	      <xsl:if test="crm:idme(monument2nd_name)=''">
		<xsl:message>deadun: <xsl:copy-of select="."/></xsl:message>
	      </xsl:if>
              <E18_Physical_Thing rdf:about="http://www.indiastudies.org/AIIS/place/{crm:idme(monument2nd_name)}">
		<xsl:call-template name="keywords"/>
                <P87_is_identified_by>
                  <E41_Appelation rdf:about="http://www.indiastudies.org/AIIS/title/{crm:idme(monument2nd_name)}">
                    <rdfs:label>
                      <xsl:value-of select="monument2nd_name"/>
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
                  <E12_Production rdf:about="http://www.indiastudies.org/AIIS/production/{crm:idme(monument2nd_name)}">
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
		    <P10_falls_within>
                      <E4_period rdf:about="http://www.indiastudies.org/AIIS/period/{crm:idme(period)}">
                        <rdfs:label>
                          <xsl:value-of select="period"/>
                        </rdfs:label>
                      </E4_period>
                    </P10_falls_within>
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
                  <E53_Place rdf:about="http://www.indiastudies.org/AIIS/monument/{crm:idme(monument2nd_name)}">
                    <P87_is_identified_by>
                      <E44_Place_Appelation rdf:about="http://www.indiastudies.org/AIIS/placename/{crm:idme(monument2nd_name)}">
                        <rdfs:label>
                          <xsl:value-of select="monument2nd_name"/>
                        </rdfs:label>
                      </E44_Place_Appelation>
                    </P87_is_identified_by>
                    <xsl:choose>
                      <xsl:when test="complex">
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
      <xsl:variable name="site" select="crm:idme(site_sub-site2nd_name)"/>
      <E53_Place rdf:about="http://www.indiastudies.org/AIIS/site/{$site}">
        <P87_is_identified_by>
          <E44_Place_Appelation rdf:about="http://www.indiastudies.org/AIIS/placename/{$site}">
            <rdfs:label>
              <xsl:value-of select="site_sub-site2nd_name"/>
            </rdfs:label>
          </E44_Place_Appelation>
        </P87_is_identified_by>
        <xsl:for-each select="doc('/Users/rahtz/SVN/Claros/tdb_builder/data/verbatim/metamorphoses-places.rdf')">
          <xsl:variable name="n" select="concat('http://id.www.indiastudies.org/places/metamorphoses/place/india-',$site)"/>
          <xsl:for-each select=".//crm:E53_Place[@rdf:about=$n]">
            <xsl:copy-of select="crm:P87_is_identified_by[crm:E47_Place_Spatial_Coordinates]"/>
          </xsl:for-each>
        </xsl:for-each>
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
