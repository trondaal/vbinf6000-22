<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
        xmlns:marc="http://www.loc.gov/MARC21/slim" 
        xmlns:xs="http://www.w3.org/2001/XMLSchema"
        exclude-result-prefixes="xs" version="2.0" 
        xmlns:fo="http://www.w3.org/1999/XSL/Format"
        xmlns:bib="http://www.example.org/bib"
        xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" 
        xmlns:skos="http://www.w3.org/2004/02/skos/core#" 
        xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#">
        
        
        <!-- 
                <xsl:variable name="format" select="fo"/>
                <xsl:output  method="xml" indent="yes"/>
                or use 
                <xsl:variable name="format" select="text"/>
                <xsl:output  method="text" indent="yes"/>
        -->
        
        <xsl:variable name="format" select="'text'"/>
        <xsl:output  method="text" indent="yes"/>
     
     
        <xsl:template match="/marc:collection">
                <xsl:choose>
                        <xsl:when test="$format eq 'fo'">
                                <fo:root font-family="Tahoma">
                                        <fo:layout-master-set>
                                                <fo:simple-page-master master-name="A4-portrait"
                                                        page-height="29.7cm" page-width="21.0cm" margin="1.0cm">
                                                        <fo:region-body/>
                                                </fo:simple-page-master>
                                        </fo:layout-master-set>
                                        <fo:page-sequence master-reference="A4-portrait">
                                                <fo:flow flow-name="xsl-region-body">
                                                        <xsl:call-template name="report"/>
                                                </fo:flow>
                                        </fo:page-sequence>
                                </fo:root>
                        </xsl:when>
                        <xsl:otherwise>
                                <xsl:call-template name="report"/>
                        </xsl:otherwise>
                </xsl:choose>     
        </xsl:template>

        <xsl:template match="marc:collection" name="report">
               
                <xsl:variable name="collection" select="."/>
                
                <!-- Heading og antall poster -->
                <xsl:copy-of select="bib:header('BIB2201 rapport over datasamling', $format)"/>              
                <xsl:copy-of select="bib:header(('Antall poster i samlingen:' || count(marc:record)), $format)"/>
                
                <!-- Diverse tester for syntaks- og andre feil -->
                <!--<xsl:call-template name="marc-errors">
                        <xsl:with-param name="collection" select="$collection"/>
                        <xsl:with-param name="format" select="$format"/>
                </xsl:call-template>-->
                
                <!-- Grupperer på 100, 110, 111 og lister titler -->
                <!--<xsl:call-template name="titler">
                        <xsl:with-param name="collection" select="$collection"/>
                        <xsl:with-param name="format" select="$format"/>
                </xsl:call-template>-->


                
                <!--
                <xsl:copy-of
                        select="bib:header('Oversikt over agenter i X00, X10, X11 - og hvilke felter de opptrer i', $format)"/>
                <xsl:for-each-group
                        select="marc:record/marc:datafield[@tag = ('100', '110', '111', '600', '610', '611', '700', '710', '711', '800', '810', '811')]"
                        group-by="replace(marc:subfield[@code = ('a')][1], '[ \.,/:]+$', '')">
                        <xsl:sort select="current-grouping-key()"/>
                        <xsl:copy-of
                                select="bib:list((current-grouping-key() || (' (' || string-join(distinct-values(current-group()/@tag), ', ') || ')')), $format)"
                        />
                </xsl:for-each-group>
                -->
                
                <!-- Leter etter agenter med URI -->
                <xsl:copy-of
                        select="bib:header('Agenter identifisert med URI', $format)"/>
                <xsl:for-each-group
                        select="marc:record/marc:datafield[@tag = ('100', '600', '700') and not(marc:subfield[@code='t']) and count(marc:subfield[@code = '1']) = 1 and starts-with(normalize-space(marc:subfield[@code = '1']), 'http')]"
                        group-by="marc:subfield[@code = ('1')][starts-with(., 'http')]/normalize-space()">
                        <xsl:sort select="(current-group()/marc:subfield[@code='a'])[1]"/>
                        <xsl:copy-of
                                select="bib:list(string-join(distinct-values(current-group()/marc:subfield[@code='a']/replace(., '[ \.,/:]+$', '')), ' / ') || ' : ' || current-grouping-key() || (' (' || string-join(distinct-values(current-group()/@tag), ', ') || ')'), $format)"
                        />
                </xsl:for-each-group>
                <xsl:if test="not(marc:record/marc:datafield[@tag = ('100', '600', '700') and not(marc:subfield[@code='t']) and marc:subfield[@code='a'] and marc:subfield[@code = '1']])">
                        <xsl:copy-of select="bib:list('Finner ingen agenter  identifisert med URI i $1', $format)"/>
                </xsl:if> 
                 
                <!-- Leter etter felter med agenter uten URI -->
                <xsl:variable name="missingagents" select="marc:record/marc:datafield[@tag = ('100', '600', '700') and not(marc:subfield[@code='t']) and not(marc:subfield/@code = '1')]"/>
                <xsl:if test="count($missingagents) > 0">
                        <xsl:copy-of
                                select="bib:header(('Agent-innførsler som IKKE er identifiser med URI i $1', 'men dere velger selv hvilke agenter som skal være med'), $format)"/>
                        <xsl:copy-of select="bib:fieldlist($missingagents, $format)"/>
                </xsl:if>

                <!-- Leter etter verk -->
                <xsl:call-template name="main-works">
                        <xsl:with-param name="collection" select="$collection"/>
                        <xsl:with-param name="format" select="$format"/>
                </xsl:call-template>

                <!-- Leter etter verk som ikke er identifisert med URI-->        
                <xsl:variable name="missingworks" select="(marc:record/marc:datafield[@tag = ('130', '240')],marc:record/marc:datafield[@tag = ('600', '700','800') and marc:subfield/@code = 't'])[not(marc:subfield/@code = '1')]"/>
                <xsl:if test="count($missingworks) > 0">
                        <xsl:copy-of
                                select="bib:header(('Innførsler som IKKE er identifisert som verk på grunn av manglende URI i $1','men det er jo ikke nødvendigvis feil!'), $format)"/>
                        <xsl:copy-of select="bib:fieldlist($missingworks, $format)"/>
                </xsl:if>
                
                <!-- Leter etter poster som ikke har verk identifisert med URI-->        
                <xsl:variable name="missingworkuris" select="marc:record[not(marc:datafield[@tag = ('130', '240')]/marc:subfield/@code = '1') and not (marc:datafield[@tag = ('700', '710', '711') and @ind2 eq '2'][marc:subfield/@code = '1'][marc:subfield/@code = 't']) and not (marc:datafield[@tag = ('730') and @ind2 eq '2'][marc:subfield/@code = '1'][marc:subfield/@code = 'a'])] "/>
                <xsl:if test="count($missingworkuris) > 0">
                        <xsl:copy-of
                                select="bib:header(('Poster hvor vi ikke finner noe verk identifisert med URI', 'hverken som hovedinnførsel i 130/240 eller som analytt i 700'), $format)"/>
                        <xsl:for-each select="$missingworkuris">
                                <xsl:sort select="marc:datafield[@tag='245']/marc:subfield[@code='a']"/>
                                <xsl:variable name="id" select="if (marc:controlfield[@tag = '001']) then '001 = ' || marc:controlfield[@tag = '001'][1] 
                                        else if (marc:controlfield[@tag = '003']) then '003 = ' || marc:controlfield[@tag = '003'][1]
                                        else 'Post som mangler 001 og 003 = '"/>
                                <xsl:copy-of select="bib:printasline(($id, '/',  '245$a = ', marc:datafield[@tag='245']/marc:subfield[@code='a']), $format)"/>
                        </xsl:for-each>
                </xsl:if>

                <!-- Lister URI som brukes til både verk og agent -->
                <xsl:call-template name="duplicateuris">
                        <xsl:with-param name="collection" select="$collection"/>
                        <xsl:with-param name="format" select="$format"/>
                </xsl:call-template>
               
                <!-- Oversikt over MARC 21 relator codes -->
                <!--<xsl:call-template name="relatorcodes">
                        <xsl:with-param name="collection" select="$collection"/>
                        <xsl:with-param name="format" select="$format"/>
                </xsl:call-template>-->
                
                <!-- Oversikt over URI relasjonstyper for Agent -->
                <xsl:call-template name="agenturis">
                        <xsl:with-param name="collection" select="$collection"/>
                        <xsl:with-param name="format" select="$format"/>
                </xsl:call-template>
     
                
                <!-- Agenter med URI og relasjonstyper som er brukt for disse -->
                <xsl:copy-of
                        select="bib:header('Personer med URI og relasjonstyper som er brukt for disse', $format)"/>
                <xsl:for-each-group
                        select="marc:record/marc:datafield[@tag = ('100', '110', '111', '600', '610', '611', '700', '710', '711') and not(marc:subfield[@code='t']) and starts-with(marc:subfield[@code = '1']/normalize-space(), 'http')]"
                        group-by="marc:subfield[@code = ('1')][starts-with(., 'http')]/normalize-space(.)">
                        <xsl:sort select="(current-group()/marc:subfield[@code='a'])[1]"/>
                        <xsl:copy-of
                                select="bib:listheader(current-grouping-key() || (' (' || string-join(distinct-values(current-group()/@tag), ', ') || ') : ' || string-join(distinct-values(current-group()/marc:subfield[@code='a']/replace(., '[ \.,/:]+$', '')), ' / ')    ), $format)"
                        />
                        <xsl:for-each-group select="current-group()" group-by="marc:subfield[@code = ('4') and starts-with(normalize-space(.), 'http')]/normalize-space()">
                                <xsl:variable name="label" select="document('rda.labels.rdf')/rdf:RDF/rdf:Description[@rdf:about eq current-grouping-key()]/rdfs:label"/>
                                <xsl:copy-of
                                        select="bib:list(current-grouping-key() || ' (' || $label || ')', $format)"
                                />
                        </xsl:for-each-group>

                </xsl:for-each-group>
                
                <!-- Verk til verk relasjonstyper brukt -->
                <xsl:call-template name="wortoworkrelationshiptypes">
                        <xsl:with-param name="collection" select="$collection"/>
                        <xsl:with-param name="format" select="$format"/>
                </xsl:call-template>
                
                <xsl:copy-of
                        select="bib:header(('Analytter (dvs en publikasjon som har flere deler)', 'I praksis er det 700-felter med ind2=2, $t og $1'), $format)"/>
                <xsl:choose>
                        <xsl:when test="marc:record/marc:datafield[@tag = ('700', '710', '711') and marc:subfield[@code = 't'] and marc:subfield[@code = '1'] and @ind2 eq '2']">
                                <xsl:for-each select="marc:record[marc:datafield[@tag = ('700', '710', '711') and marc:subfield[@code = 't'] and marc:subfield[@code = '1'] and @ind2 eq '2']]">
                                        <xsl:variable name="id" select="if (marc:controlfield[@tag = '001']) then '001 = ' || marc:controlfield[@tag = '001'][1] 
                                                else if (marc:controlfield[@tag = '003']) then '003 = ' || marc:controlfield[@tag = '003'][1]
                                                else 'Post som mangler 001 og 003 = '"/>
                                        <xsl:copy-of
                                                select="bib:listheader($id, $format)"
                                        />
                                        <xsl:variable name="mainauthor" select="marc:datafield[@tag = ('100') and marc:subfield[@code = '1']]"/>
                                        <xsl:variable name="collectionwork" select="marc:datafield[@tag = ('130', '240') and marc:subfield[@code = '1']]"/>
                                        <xsl:variable name="titlestatement" select="marc:datafield[@tag = ('245')]"/>
                                        <xsl:variable name="fields" select="marc:datafield[@tag = ('700', '710', '711') and marc:subfield[@code = 't'] and @ind2 eq '2']"/>
                                        <xsl:copy-of select="bib:fieldlist(($mainauthor | $collectionwork | $titlestatement | $fields), $format)"/>
                                </xsl:for-each>
                        </xsl:when>
                        <xsl:otherwise>
                                <xsl:copy-of
                                        select="bib:printasline('Ser ut som dere mangler slike poster?', $format)"/>
                        </xsl:otherwise>
                </xsl:choose>
                
                <!-- Verk til verk relasjoner -->
                <xsl:call-template name="wortoworkrelationships">
                        <xsl:with-param name="collection" select="$collection"/>
                        <xsl:with-param name="format" select="$format"/>
                </xsl:call-template>               
    
                <!-- Poster med felt hvor $i OG $4 burde vært med i 700 felt -->
                <xsl:if test="marc:record[marc:datafield[@tag = ('700', '710', '711') and not(marc:subfield[@code = '4']) and not(@ind2 = '2') and marc:subfield[@code = 't']]]">
                        <xsl:copy-of
                                select="bib:header('Poster med felt hvor $4 burde vært med i 700 felt', $format)"/>
                        <xsl:for-each
                                select="marc:record[marc:datafield[@tag = ('700', '710', '711') and not(marc:subfield[@code = '4']) and not(@ind2 = '2') and marc:subfield[@code = 't']]]">
                                <xsl:variable name="id" select="if (marc:controlfield[@tag = '001']) then '001  ' || marc:controlfield[@tag = '001'][1] else if (marc:controlfield[@tag = '003']) then '003  '||marc:controlfield[@tag = '003'][1] else '(posten mangler 001/003)'"/>
                                <xsl:copy-of select="bib:printasline($id, $format)"/>
                                <xsl:variable name="fields" select="marc:datafield[@tag = ('700', '710', '711') and not(marc:subfield[@code = '4']) and not(@ind2 = '2') and marc:subfield[@code = 't']]"/>
                                <xsl:copy-of select="bib:fieldlist($fields, $format)"/>
                        </xsl:for-each>
                        <xsl:copy-of
                                select="bib:newline()"
                        />
                </xsl:if>
                
 

                <xsl:copy-of select="bib:header('Opplisting som viser bruken av 336 $a, $b, $0, $2', $format)"/>
                <xsl:for-each-group select="/*//marc:datafield[@tag = ('336')]"
                        group-by="marc:subfield[@code = 'a'][1] || marc:subfield[@code = 'b'][1] || marc:subfield[@code = '0'][1] || marc:subfield[@code = '2'][1]">
                        <xsl:copy-of select="bib:fieldlist(current-group()[1], $format)"/>
                </xsl:for-each-group>
                
                <xsl:copy-of select="bib:header('Opplisting som viser bruken av 337 $a, $b, $0, $2', $format)"/>
                <xsl:for-each-group select="/*//marc:datafield[@tag = ('337')]"
                        group-by="marc:subfield[@code = 'a'][1] || marc:subfield[@code = 'b'][1] || marc:subfield[@code = '0'][1] || marc:subfield[@code = '2'][1]">
                        <xsl:copy-of select="bib:fieldlist(current-group()[1], $format)"/>
                </xsl:for-each-group>
                
                <xsl:copy-of select="bib:header('Opplisting som viser bruken av 338 $a, $b, $0, $2', $format)"/>
                <xsl:for-each-group select="/*//marc:datafield[@tag = ('338')]"
                        group-by="marc:subfield[@code = 'a'][1] || marc:subfield[@code = 'b'][1] || marc:subfield[@code = '0'][1] || marc:subfield[@code = '2'][1]">
                        <xsl:copy-of select="bib:fieldlist(current-group()[1], $format)"/>
                </xsl:for-each-group>

                <xsl:copy-of select="bib:header('Opplisting som viser bruken av 380 $a, $0, $2', $format)"/>
                <xsl:for-each-group select="/*//marc:datafield[@tag = ('380')]"
                        group-by="marc:subfield[@code = 'a'][1] || marc:subfield[@code = '0'][1] || marc:subfield[@code = '2'][1]">
                        <xsl:copy-of select="bib:fieldlist(current-group()[1], $format)"/>
                </xsl:for-each-group>
    
                <!-- Poster som mangler 336, 337, 338, 380 (tom liste = bra) -->
                <xsl:variable name="fields" select="marc:record[not(marc:datafield[@tag = ('336')]) or not(marc:datafield[@tag = ('337')]) or not(marc:datafield[@tag = ('338')]) or not(marc:datafield[@tag = ('380')])]"/>
                <xsl:if test="count($fields) > 0">
                        <xsl:copy-of select="bib:header('Poster som mangler 336, 337, 338, 380', $format)"/>
                        <xsl:for-each select="$fields">
                                <xsl:variable name="id" select="if (marc:controlfield[@tag = '001']) then marc:controlfield[@tag = '001'] else '(posten mangler 001)'"/>
                                <xsl:variable name="tags" as="node() *">
                                        <xsl:if test="not(marc:datafield[@tag = ('336')])">
                                                <xsl:value-of select="'336'"/>
                                        </xsl:if>
                                        <xsl:if test="not(marc:datafield[@tag = ('337')])">
                                                <xsl:value-of select="'337'"/>
                                        </xsl:if>
                                        <xsl:if test="not(marc:datafield[@tag = ('338')])">
                                                <xsl:value-of select="'338'"/>
                                        </xsl:if>
                                        <xsl:if test="not(marc:datafield[@tag = ('380')])">
                                                <xsl:value-of select="'380'"/>
                                        </xsl:if>        
                                </xsl:variable>
                                <xsl:copy-of select="bib:printasline(('001:', $id, 'mangler følgende felt: ', string-join($tags, ', ')), $format)"/>
                        </xsl:for-each>
                </xsl:if>
        </xsl:template>
        
        
        <!-- FUNCTIONS FOR FORMATTING OUTPUT -->
        
        <xsl:function name="bib:header">
                <xsl:param name="input"/>
                <xsl:param name="format"/>
                <xsl:choose>
                        <xsl:when test="$format = 'fo'">
                                <fo:block space-after="4mm">
                                <fo:block font-size="12pt" text-align="left" font-weight="bold" space-before="10mm" keep-with-next="always">
                                        <xsl:value-of select="$input[1]"/>
                                </fo:block>
                                <xsl:for-each select="$input[position() > 1]">
                                        <fo:block font-size="10pt" text-align="left" font-weight="bold">
                                                <xsl:value-of select="."/>
                                        </fo:block>
                                </xsl:for-each>
                                </fo:block>
                        </xsl:when>
                        <xsl:otherwise>
                                <xsl:value-of select="bib:newline() || bib:newline()"/>
                                <xsl:value-of select="$input[1] || bib:newline()"/>
                                <xsl:for-each select="$input[position() > 1]">
                                        <xsl:value-of select=". || bib:newline()"/>
                                        
                                </xsl:for-each>
                                <xsl:value-of select="bib:ruler()"/>
                        </xsl:otherwise>
                </xsl:choose>           
        </xsl:function>
        
        <xsl:function name="bib:ruler">
                <xsl:choose>
                        <xsl:when test="$format='fo'">
                                <fo:block>
                                        <fo:leader leader-length="7.5in" leader-pattern="rule"
                                                rule-thickness="2pt" color="green"/>
                                </fo:block>
                        </xsl:when>
                        <xsl:otherwise>
                                <xsl:value-of select="string-join('-------------------------------------------------------') || '&#xa;'"/>
                        </xsl:otherwise>
                </xsl:choose>
        </xsl:function>
        
        <xsl:function name="bib:print">
                <xsl:param name="input"/>
                <xsl:param name="format"/>
                <xsl:value-of select="string-join($input, ' ')"/>
        </xsl:function>
        
        <xsl:function name="bib:print-nolinebreak">
                <xsl:param name="input"/>
                <xsl:param name="format"/>
                <xsl:choose>
                        <xsl:when test="$format = 'fo'">
                                <fo:inline keep-together.within-line="always"><xsl:value-of select="string-join($input, ' ')"/></fo:inline>
                                
                        </xsl:when>
                        <xsl:otherwise>
                                <xsl:value-of select="string-join($input, ' ')"/>
                        </xsl:otherwise>
                </xsl:choose>
                
        </xsl:function>
                
        <xsl:function name="bib:printaslines">
                <xsl:param name="input"/>
                <xsl:param name="format"/>
                <xsl:choose>
                        <xsl:when test="$format = 'fo'">
                                <xsl:for-each select="$input">
                                        <fo:block font-size="10pt" text-align="left">
                                                <xsl:value-of select="."/>
                                        </fo:block>
                                </xsl:for-each>
                        </xsl:when> 
                        <xsl:otherwise>
                                <xsl:value-of select="string-join(($input, '&#xa;'), '&#xa;')"/>
                        </xsl:otherwise>
                </xsl:choose>
                
        </xsl:function>
        
        
        <xsl:function name="bib:printasline">
                <xsl:param name="input"/>
                <xsl:param name="format"/>
                <xsl:choose>
                        <xsl:when test="$format = 'fo'">
                                <fo:block font-size="10pt" text-align="left">
                                        <xsl:value-of select="$input"/>
                                </fo:block>                              
                        </xsl:when> 
                        <xsl:otherwise>
                                <xsl:value-of select="string-join(($input, '&#xa;'), ' ')"/>
                        </xsl:otherwise>
                </xsl:choose>
        </xsl:function>
        

        <xsl:function name="bib:newline" as="xs:string">
                <xsl:value-of select="'&#xa;'"/>
        </xsl:function>
        
        <xsl:function name="bib:fieldlist">
                <xsl:param name="fields"/>
                <xsl:param name="format"/>
                <xsl:choose>
                        <xsl:when test="$format eq 'fo'">
                                <fo:list-block provisional-distance-between-starts="20pt" provisional-label-separation="6pt">
                                        <xsl:for-each select="$fields">
                                                <xsl:sort select="@tag"/>
                                                <!--<xsl:sort select="if (@tag=('100', '336', '337', '338', '380', '130', '240', '245','630', '730', '830')) then ./marc:subfield[@code='a'][1] else ./marc:subfield[@code='t'][1]"/> -->                                               
                                                <xsl:sort select="./marc:subfield[@code='a'][1]"/>
                                                <xsl:sort select="./marc:subfield[@code='d'][1]"/>
                                                <xsl:sort select="./marc:subfield[@code='t'][1]"/>
                                                <fo:list-item>
                                                        <fo:list-item-label end-indent="label-end()">
                                                                <fo:block>
                                                                        <fo:inline>*</fo:inline>
                                                                </fo:block>
                                                        </fo:list-item-label>
                                                        <fo:list-item-body start-indent="body-start()">
                                                                <fo:block font-size="9pt" text-align="left">
                                                                        <xsl:copy-of select="bib:printfieldasline(., $format)"/>
                                                                </fo:block>
                                                        </fo:list-item-body>
                                                </fo:list-item>
                                        </xsl:for-each> 
                                </fo:list-block>
                        </xsl:when>
                        <xsl:otherwise>
                                <xsl:for-each select="$fields">
                                        <xsl:sort select="@tag"/>
                                        <!--<xsl:sort select="if (@tag=('130', '240', '245','630', '730', '830')) then marc:subfield[@code='a'][1] else marc:subfield[@code='t'][1]"/>  -->
                                        <xsl:sort select="./marc:subfield[@code='a'][1]"/>
                                        <xsl:sort select="./marc:subfield[@code='d'][1]"/>
                                        <xsl:sort select="./marc:subfield[@code='t'][1]"/>
                                        <xsl:copy-of select="bib:printfieldasline(., $format)"/>
                                </xsl:for-each>                                
                        </xsl:otherwise>
                </xsl:choose>
        </xsl:function>
        
        <xsl:function name="bib:listheader">
                <xsl:param name="input"/>
                <xsl:param name="format"/>
                <xsl:choose>
                        <xsl:when test="$format = 'fo'">
                                <fo:block font-size="9pt" font-weight="bold" text-align="left" space-before='1mm'>
                                        <xsl:value-of select="$input[1]"/>
                                </fo:block>
                                <xsl:for-each select="$input[position() > 1]">
                                        <fo:block font-size="9pt" font-weight="bold" text-align="left">
                                                <xsl:value-of select="."/>
                                        </fo:block>
                                </xsl:for-each>
                        </xsl:when> 
                        <xsl:otherwise>
                                <xsl:value-of select="string-join(($input, '&#xa;'), ' ')"/>
                        </xsl:otherwise>
                </xsl:choose>
        </xsl:function>
        
        <xsl:function name="bib:list">
                <xsl:param name="values"/>
                <xsl:param name="format"/>
                <xsl:choose>
                        <xsl:when test="$format eq 'fo'">
                                <fo:list-block provisional-distance-between-starts="20pt" provisional-label-separation="6pt">
                                        <xsl:for-each select="$values">
                                                <fo:list-item space-after="-2pt">
                                                        <fo:list-item-label end-indent="label-end()">
                                                                <fo:block>
                                                                        <fo:inline>*</fo:inline>
                                                                </fo:block>
                                                        </fo:list-item-label>
                                                        <fo:list-item-body start-indent="body-start()">
                                                                <fo:block font-size="9pt" font-weight="normal"><xsl:copy-of select="."/></fo:block>
                                                        </fo:list-item-body>
                                                </fo:list-item>
                                        </xsl:for-each> 
                                </fo:list-block>
                        </xsl:when>
                        <xsl:otherwise>
                                <xsl:for-each select="$values">
                                        <xsl:value-of select="'* ' || normalize-space(.) || bib:newline()"/>
                                </xsl:for-each>                                
                        </xsl:otherwise>
                </xsl:choose>
        </xsl:function>
        
        <xsl:function name="bib:printfieldasline">
                <xsl:param name="field"/>
                <xsl:param name="format"/>
                <xsl:copy-of select="bib:print((if ($format ne 'fo') then '* ' else '') || $field/@tag, $format)"/>
                <xsl:copy-of select="bib:print((' ', concat(if ($field/@ind1 eq ' ') then '#' else $field/@ind1, if ($field/@ind2 eq ' ') then '#' else $field/@ind2)), $format)"/>
                <xsl:for-each select="$field/marc:subfield[matches(@code, '[a-z]')]">
                        <xsl:sort select="@code"/>
                        <xsl:copy-of
                                select="bib:print('  ' || '$' || @code || normalize-space(.), $format)"
                        />
                </xsl:for-each>
                <xsl:for-each select="$field/marc:subfield[matches(@code, '[0-9]')]">
                        <xsl:sort select="@code"/>
                        <xsl:choose>
                                <xsl:when test="matches(./@code, '[014]')">
                                        <xsl:copy-of
                                                select="bib:print-nolinebreak('  ' || '$' || @code || normalize-space(.), $format)"
                                        />
                                </xsl:when>
                                <xsl:otherwise>
                                        <xsl:copy-of
                                                select="bib:print(' ' || '$' || @code || normalize-space(.), $format)"
                                        />
                                </xsl:otherwise>
                        </xsl:choose>
                        
                </xsl:for-each>
                <xsl:if test="$format ne 'fo'">
                        <xsl:value-of
                                select="bib:newline()"
                        />
                </xsl:if>
        </xsl:function>
        
        <xsl:template name="marc-errors">
                <!-- Leter etter verk -->   
                <xsl:param name="collection" required="yes"/>
                <xsl:param name="format" required="yes"/>
                
                <!-- Diverse tester for syntaks- og andre feil -->
                <xsl:copy-of select="bib:header('Diverse sjekker for syntaksfeil i postene&#x2028;(tom liste = ingen mistenkelige feil)', $format)"/>
                
                <xsl:choose>
                        <xsl:when test="marc:record/marc:datafield[@tag = ('100', '240', '245', '600', '700', '800') and not(marc:subfield[@code = 'a'])]">
                                <xsl:copy-of select="bib:listheader(('X00-felt som mangler $a: ' || count(marc:record/marc:datafield[@tag = ('100', '240', '245', '600', '700', '800') and not(marc:subfield[@code = 'a'])])), $format)"/>
                                <xsl:variable name="fields" select="marc:record/marc:datafield[@tag = ('100', '240', '245', '600', '700', '800') and not(marc:subfield[@code = 'a'])]"/>
                                <xsl:copy-of select="bib:fieldlist($fields, $format)"/>
                        </xsl:when>
                        <xsl:otherwise>
                                <!--<xsl:value-of select="bib:printasline('Bra! Ingen 100/130/240/245/600/700/800 som mangler $a.')"/>-->
                        </xsl:otherwise>
                </xsl:choose>
                
                <xsl:choose>
                        <xsl:when test="marc:record/marc:datafield[@tag = ('100', '240', '245', '600', '700', '800') and count(marc:subfield[@code = 'a']) &gt; 1]">
                                <xsl:copy-of select="bib:listheader(('X00 felt som har mer enn ett subfelt $a: ' || count(marc:record/marc:datafield[@tag = ('100', '240', '245', '600', '700', '800') and count(marc:subfield[@code = 'a']) &gt; 1])), $format)"/>
                                <xsl:variable name="fields" select="marc:record/marc:datafield[@tag = ('100', '240', '245', '600', '700', '800') and count(marc:subfield[@code = 'a']) &gt; 1]"/>
                                <xsl:copy-of select="bib:fieldlist($fields, $format)"/>
                        </xsl:when>
                        <xsl:otherwise>
                                <!--<xsl:value-of select="bib:printasline('Bra! Ingen repeterte $a i 100/130/240/245/600/700/800.')"/>-->
                        </xsl:otherwise>
                </xsl:choose>
                <xsl:choose>
                        <xsl:when test="marc:record/marc:datafield[@tag = ('100', '110', '111', '130', '240', '245', '600', '610', '611', '630', '700', '710', '711', '730', '800', '810', '811', '830')]/marc:subfield[@code = 'a' and . eq '']">
                                <xsl:value-of select="bib:listheader(('Felt som har tom verdi i $a (feltet finnes, men har ingen verdi)', (marc:record/marc:datafield[@tag = ('100', '110', '111', '130', '240', '245', '600', '610', '611', '630', '700', '710', '711', '730', '800', '810', '811', '830')]/marc:subfield[@code = 'a' and . eq ''])), $format)"/>
                                <xsl:variable name="fields" select="marc:record/marc:datafield[@tag = ('100', '110', '111', '130', '240', '245', '600', '610', '611', '630', '700', '710', '711', '730', '800', '810', '811', '830')][marc:subfield[@code = 'a' and . eq '']]"/>
                                <xsl:value-of select="bib:fieldlist($fields, $format)"/>
                        </xsl:when>
                        <xsl:otherwise>
                                <!--<xsl:value-of select="bib:printasline('Bra! Ingen tomme $a-felt i 100/130/240/245/600/700/800.')"/>-->
                        </xsl:otherwise>
                </xsl:choose>
                <xsl:choose>
                        <xsl:when test="marc:record[count(marc:controlfield[@tag = '001']) &gt; 1]">
                                <xsl:copy-of select="bib:listheader(('Poster som har flere enn ett kontrollfelt 001:', count(marc:record[count(marc:controlfield[@tag = '001']) &gt; 1])), $format)"/>
                        </xsl:when>
                        <xsl:otherwise>
                                <!--<xsl:value-of select="bib:printasline('Bra! Ingen repeterte 001-felt')"/>-->
                        </xsl:otherwise>
                </xsl:choose>
                <xsl:choose>
                        <xsl:when test="marc:record[not(marc:controlfield[@tag = '001'])]">
                                <xsl:copy-of select="bib:listheader('Poster som mangler kontrollfelt 001: ' || count(marc:record[not(marc:controlfield[@tag = '001'])]), $format)"/>
                        </xsl:when>
                        <xsl:otherwise>
                                <!--<xsl:value-of select="bib:printasline('Bra! Ingen poster som mangler 001')"/>-->
                        </xsl:otherwise>
                </xsl:choose>
                <xsl:choose>
                        <xsl:when test="marc:record[count(marc:datafield[@tag = '100']) &gt; 1]">
                                <xsl:copy-of select="bib:listheader('Poster som har flere enn ett 100-felt: ' || count(marc:record[count(marc:datafield[@tag = '100']) &gt; 1]), $format)"/>
                        </xsl:when>
                        <xsl:otherwise>
                                <!--<xsl:value-of select="bib:printasline('Bra! Ingen repeterte 100-felt')"/>-->
                        </xsl:otherwise>
                </xsl:choose>
                <xsl:choose>
                        <xsl:when test="marc:record[count(marc:datafield[@tag = '130']) &gt; 1]">
                                <xsl:copy-of select="bib:listheader('Poster som har flere enn ett 130-felt: ' || count(marc:record[count(marc:datafield[@tag = '130']) &gt; 1]), $format)"/>
                        </xsl:when>
                        <xsl:otherwise>
                                <!--<xsl:value-of select="bib:printasline('Bra! Ingen repeterte 130-felt')"/>-->
                        </xsl:otherwise>
                </xsl:choose>
                <xsl:choose>
                        <xsl:when test="marc:record[count(marc:datafield[@tag = '240']) &gt; 1]">
                                <xsl:copy-of select="bib:listheader('Poster som har flere enn ett 240-felt: '|| count(marc:record[count(marc:datafield[@tag = '240']) &gt; 1]), $format)"/>
                        </xsl:when>
                        <xsl:otherwise>
                                <!--<xsl:value-of select="bib:printasline('Bra! Ingen repeterte 240-felt')"/>-->
                        </xsl:otherwise>
                </xsl:choose>
                <xsl:choose>
                        <xsl:when test="../marc:collection/*[not(local-name(.) = ('record'))]">
                                <xsl:copy-of select="bib:listheader(('Mistenkelig bruk av ugyldig elementnavn under collection-element for ', count(../marc:collection/*[not(local-name(.) = ('record'))]), 'felter (du bør sjekke xml-strukturen)'), $format)"/>
                        </xsl:when>
                        <xsl:otherwise>
                                
                        </xsl:otherwise>
                </xsl:choose>
                <xsl:choose>
                        <xsl:when test="marc:record/*[not(local-name(.) = ('leader', 'datafield', 'controlfield'))]">
                                <xsl:copy-of select="bib:listheader(('Mistenkelig bruk av ugyldig elementnavn under record-element i', count(marc:record/*[not(local-name(.) = ('leader', 'datafield', 'controlfield'))]), 'poster (du bør sjekke xml-strukturen)'), $format)"/>
                        </xsl:when>
                        <xsl:otherwise>
                                
                        </xsl:otherwise>
                </xsl:choose>
                <xsl:choose>
                        <xsl:when test="marc:record/marc:datafield/*[not(local-name(.) = ('subfield'))]">
                                <xsl:value-of select="bib:listheader(('Mistenkelig bruk av ugyldig elementnavn under datafield-element i', count(marc:record/marc:datafield/*[not(local-name(.) = ('subfield'))]), 'poster (du bør sjekke xml-strukturen)'), $format)"/>
                        </xsl:when>
                        <xsl:otherwise>
                                
                        </xsl:otherwise>
                </xsl:choose>
                
                <xsl:choose>
                        <xsl:when test="marc:record/marc:datafield[count(marc:subfield[@code='1' and starts-with(normalize-space(.), 'http')]) > 1]">
                                <xsl:copy-of select="bib:listheader(('Mistenkelig bruk av flere $1 med URI i samme datafelt','($1 bruker vi til ENTEN å identifisere agent ELLER verk)'), $format)"/>
                                <xsl:variable name="fields" select="marc:record/marc:datafield[count(marc:subfield[@code='1' and starts-with(normalize-space(.), 'http')]) > 1]"/>
                                <xsl:copy-of select="bib:fieldlist($fields, $format)"/>
                        </xsl:when>
                        <xsl:otherwise>
                                
                        </xsl:otherwise>
                </xsl:choose>
                
                <xsl:choose>
                        <xsl:when test="marc:record/marc:datafield[count(marc:subfield[@code='4' and starts-with(normalize-space(.), 'http')]) > 1]">
                                <xsl:copy-of select="bib:listheader(('Mistenkelig bruk av flere $4 med URI i samme datafelt', '$4 med URI brukes til ENTEN å identifisere relasjon til agent ELLER til verk,', 'men helt greit om det er flere $4 så lenge de peker til samme entitet)'), $format)"/>
                                <xsl:variable name="fields" select="marc:record/marc:datafield[count(marc:subfield[@code='4' and starts-with(normalize-space(.), 'http')]) > 1]"/>
                                <xsl:copy-of select="bib:fieldlist($fields, $format)"/>
                        </xsl:when>
                        <xsl:otherwise>
                                
                        </xsl:otherwise>
                </xsl:choose>
                
                <xsl:choose>
                        <xsl:when test="marc:record/marc:datafield/marc:subfield[@code = '1' and not(contains(., 'http'))]">
                                <xsl:copy-of select="bib:listheader('Mistenkelige verdier i $1:', $format)"/>
                                <xsl:variable name="fields" select="marc:record/marc:datafield[marc:subfield[@code = '1' and not(contains(., 'http'))]]"/>
                                <xsl:copy-of select="bib:fieldlist($fields, $format)"/>
                        </xsl:when>
                        <xsl:otherwise>
                                
                        </xsl:otherwise>
                </xsl:choose>
                
                <xsl:if test="marc:record/marc:datafield[@tag='245' and marc:subfield/@code = '1']">
                        <xsl:variable name="fields" select="marc:record/marc:datafield[@tag='245' and marc:subfield/@code = '1']"/>
                        <xsl:copy-of select="bib:listheader('Bruk av $1 i 245 (som tyder på litt misforståelse siden 245 ikke har feltet $1 og dere burde kanskje brukt 240)', $format)"/>
                        <xsl:copy-of select="bib:fieldlist($fields, $format)"/>
                </xsl:if>
                
                <!-- Diverse tester på $4 -->
                <xsl:copy-of
                        select="bib:header(('Verdier i $4 som muligens er feil', 'tom liste = ingen feil'), $format)"/>
                <xsl:if test="$collection//marc:datafield[@tag = ('100', '110', '111', '700', '710', '711')]/marc:subfield[@code = '4'][string-length(.) ne 3 and not(starts-with(normalize-space(.), 'http'))]">
                        <xsl:for-each-group
                                select="/*//marc:datafield[@tag = ('100', '110', '111', '700', '710', '711')]/marc:subfield[@code = '4']/normalize-space()"
                                group-by="." >
                                <xsl:sort select="current-grouping-key()"/>
                                <xsl:if test="string-length(current-grouping-key()) ne 3 and not(starts-with(current-grouping-key(), 'http'))">
                                        <xsl:copy-of
                                                select="bib:printasline(string-join((if (current-grouping-key() eq '') then 'tomt subfelt' else current-grouping-key(), count(current-group()), 'Feil kode?'), '  : '), $format)"
                                        />
                                </xsl:if>
                        </xsl:for-each-group>
                </xsl:if>
                <xsl:if test="/*//marc:datafield[@tag = ('100', '110', '111', '700', '710', '711')]/marc:subfield[@code = '4'][starts-with(normalize-space(.), 'http')]">
                        <xsl:for-each-group
                                select="/*//marc:datafield[@tag = ('100', '110', '111', '700', '710', '711')]/marc:subfield[@code = '4'][starts-with(normalize-space(.), 'http')]/normalize-space()"
                                group-by="." >
                                <xsl:sort select="current-grouping-key()"/>
                                <xsl:choose>
                                        <xsl:when test="not(xs:anyURI(current-grouping-key()))">
                                                <xsl:copy-of
                                                        select="bib:printasline(string-join((current-grouping-key(), count(current-group()), 'Ugyldig URI?'), '  : '), $format)"
                                                />
                                        </xsl:when>
                                        <xsl:when test="not(starts-with(current-grouping-key(), 'http://rdaregistry.info/Elements/'))">
                                                <xsl:copy-of
                                                        select="bib:printasline(string-join((current-grouping-key(), count(current-group()), 'Feil RDA adresse?'), '  : '), $format)"
                                                />
                                        </xsl:when>
                                        <xsl:when test="not(matches(current-grouping-key(), 'P\d\d\d\d\d$'))">
                                                <xsl:copy-of
                                                        select="bib:printasline(string-join((current-grouping-key(), count(current-group()), 'Feil P-nummer (skal være P + fem siffer på slutten'), '  : '), $format)"
                                                />
                                        </xsl:when>
                                        <xsl:otherwise></xsl:otherwise>
                                </xsl:choose>
                        </xsl:for-each-group>
                </xsl:if>
                <xsl:if test="marc:record[marc:datafield[@tag = ('100', '110', '111', '700', '710', '711') and not(marc:subfield[@code = '4']) and not(marc:subfield[@code = 't'])]]">
                        <xsl:copy-of
                                select="bib:header(('Poster med felt hvor $4 mangler i 100, 110, 111, 700, 710, 711', 'Vi har fokus på 700-feltet'), $format)"/>
                        <xsl:for-each
                                select="marc:record[marc:datafield[@tag = ('100', '110', '111', '700', '710', '711') and not(marc:subfield[@code = '4']) and not(marc:subfield[@code = 't'])]]">
                                <xsl:variable name="id" select="if (marc:controlfield[@tag = '001']) then marc:controlfield[@tag = '001'][1] else '(posten mangler 001)'"/>
                                <xsl:variable name="fields" select="marc:datafield[@tag = ('100', '110', '111', '700', '710', '711') and not(marc:subfield[@code = '4']) and not(marc:subfield[@code = 't'])]"/>
                                <xsl:copy-of select="bib:fieldlist($fields, $format)"/>
                        </xsl:for-each>
                </xsl:if>
                
        </xsl:template>
        
        <xsl:template name="titler">
                <!-- Grupperer på 100, 110, 111 og lister titler i 240 eller 245 -->
                <xsl:param name="collection" required="yes"/>
                <xsl:param name="format" required="yes"/>
                <xsl:copy-of select="bib:header('Oversikt over titler med hovedinnførsel på agent i 1XX', $format)"/>
                <xsl:for-each-group select="marc:record[marc:datafield[@tag = ('100', '110', '111')]]"
                        group-by="replace((marc:datafield[@tag = ('100', '110', '111')]/marc:subfield[@code = 'a'])[1], '[ \.,/:]+$', '')">
                        <xsl:sort select="current-grouping-key()"/>
                        <xsl:copy-of select="bib:listheader(current-grouping-key()[1], $format)"/>
                        <xsl:for-each-group select="current-group()"
                                group-by="replace((marc:datafield[@tag = '240']/marc:subfield[@code = 'a'], marc:datafield[@tag = '245']/marc:subfield[@code = 'a'])[1], '[ \.,/:]+$', '')">
                                <xsl:sort select="current-grouping-key()"/>
                                <xsl:copy-of select="bib:list(current-grouping-key()[1], $format)"/>
                        </xsl:for-each-group>
                </xsl:for-each-group>
        </xsl:template>
        
        <xsl:template name="main-works">
                <!-- Leter etter verk -->   
                <xsl:param name="collection" required="yes"/>
                <xsl:param name="format" required="yes"/>
                <xsl:copy-of
                        select="bib:header('Verk identifisert med URI', $format)"/>
                <xsl:choose>
                        <xsl:when test="$format eq 'fo'">
                                <fo:list-block provisional-distance-between-starts="20pt" provisional-label-separation="6pt">
                                        <xsl:for-each-group
                                                select="($collection/marc:record/marc:datafield[@tag = ('130', '240', '630', '730', '830')]/marc:subfield[@code='1']/normalize-space(.), marc:record/marc:datafield[@tag = ('600', '610', '611', '700', '710', '711') and marc:subfield[@code='t']]/marc:subfield[@code = '1']/normalize-space(.), marc:record/marc:datafield[@tag = ('800', '810', '811')]/marc:subfield[@code = '1']/normalize-space(.))"
                                                group-by=".">
                                                <xsl:sort select="($collection/marc:record/marc:datafield[@tag = ('130', '240', '630', '730', '758', '830') and marc:subfield[@code='1'][normalize-space(.) eq current-grouping-key() and current-grouping-key() ne '']]/marc:subfield[@code='a'],
                                                        $collection/marc:record/marc:datafield[@tag = ('600', '610', '611', '700', '710', '711', '800', '810', '811') and marc:subfield[@code='1'][normalize-space(.) eq current-grouping-key() and current-grouping-key() ne '']]/marc:subfield[@code='t'])[1]"/>
                                                <xsl:variable name="a-fields" select="$collection/marc:record/marc:datafield[@tag = ('130', '240', '630', '730', '758', '830') and marc:subfield[@code='1'][normalize-space(.) eq current-grouping-key() and current-grouping-key() ne '']]"/>
                                                <xsl:variable name="t-fields" select="$collection/marc:record/marc:datafield[@tag = ('600', '610', '611', '700', '710', '711', '800', '810', '811') and marc:subfield[@code='1'][normalize-space(.) eq current-grouping-key() and current-grouping-key() ne '']]"/>
                                                <!--<xsl:variable name="titles" select="($collection/marc:record/marc:datafield[@tag = ('130', '240', '630', '730', '830') and marc:subfield[@code='1'][contains(., current-grouping-key()) and current-grouping-key() ne '']]/marc:subfield[@code='a'], $collection/marc:record/marc:datafield[@tag = ('600', '610', '611', '700', '710', '711', '800', '810', '811') and marc:subfield[@code='1'][contains(., current-grouping-key()) and current-grouping-key() ne '']]/marc:subfield[@code='t'])"/>-->
                                                <xsl:variable name="titles" select="distinct-values((for $s in $a-fields return string-join(($s/marc:subfield[@code='a'],$s/marc:subfield[@code='p']), ' : '), for $s in $t-fields return string-join(($s/marc:subfield[@code='t'],$s/marc:subfield[@code='p']), ' : ')))"/>
                                                <xsl:variable name="types" select="($a-fields[@tag = ('130', '240')], $a-fields[@tag = ('730')][@ind2='2'], $t-fields[@tag = ('700', '710', '711')][@ind2='2'])/../marc:datafield[@tag='380']/marc:subfield[@code='a']"/>
                                                <fo:list-item>
                                                        <fo:list-item-label end-indent="label-end()">
                                                                <fo:block>
                                                                        <fo:inline>*</fo:inline>
                                                                </fo:block>
                                                        </fo:list-item-label>
                                                        <fo:list-item-body start-indent="body-start()">
                                                                <fo:block font-size="9pt" text-align="left">
                                                                        <xsl:variable name="distinct-titles">
                                                                                <xsl:sequence>
                                                                                        <xsl:for-each-group select="$titles" group-by="lower-case(replace(., '\W', ''))">
                                                                                                <title>
                                                                                                        <xsl:value-of select="current-group()[1]"/>
                                                                                                </title>
                                                                                        </xsl:for-each-group>
                                                                                </xsl:sequence>
                                                                        </xsl:variable>
                                                                        <xsl:copy-of select="current-grouping-key() || ' = ' || string-join($distinct-titles/title, ' / ') || ' '"/>
                                                                        <xsl:if test="count($types) > 0">
                                                                                <fo:inline keep-together.within-line="always">
                                                                                        <xsl:value-of select="'(' || string-join(distinct-values($types), ' / ') || ')'"/>
                                                                                </fo:inline>
                                                                        </xsl:if>
                                                                </fo:block>
                                                        </fo:list-item-body>
                                                </fo:list-item>
                                        </xsl:for-each-group>
                                </fo:list-block>
                        </xsl:when>
                        <xsl:otherwise>
                                <xsl:for-each-group
                                        select="($collection/marc:record/marc:datafield[@tag = ('130', '240', '630', '730', '830')]/marc:subfield[@code='1']/normalize-space(.), marc:record/marc:datafield[@tag = ('600', '610', '611', '700', '710', '711', '800', '810', '811') and marc:subfield[@code='t']]/marc:subfield[@code = '1']/normalize-space(.))"
                                        group-by=".">
                                        <xsl:sort select="current-grouping-key()"/>
                                        <xsl:variable name="a-fields" select="$collection/marc:record/marc:datafield[@tag = ('130', '240', '630', '730', '758', '830') and marc:subfield[@code='1'][normalize-space(.) eq current-grouping-key() and current-grouping-key() ne '']]"/>
                                        <xsl:variable name="t-fields" select="$collection/marc:record/marc:datafield[@tag = ('600', '610', '611', '700', '710', '711', '800', '810', '811') and marc:subfield[@code='1'][normalize-space(.) eq current-grouping-key() and current-grouping-key() ne '']]"/>
                                        <!--<xsl:variable name="titles" select="($collection/marc:record/marc:datafield[@tag = ('130', '240', '630', '730', '830') and marc:subfield[@code='1'][contains(., current-grouping-key()) and current-grouping-key() ne '']]/marc:subfield[@code='a'], $collection/marc:record/marc:datafield[@tag = ('600', '610', '611', '700', '710', '711', '800', '810', '811') and marc:subfield[@code='1'][contains(., current-grouping-key()) and current-grouping-key() ne '']]/marc:subfield[@code='t'])"/>-->
                                        <xsl:variable name="titles" select="distinct-values(($a-fields/marc:subfield[@code='a'], $t-fields/marc:subfield[@code='t']))"/>
                                        <xsl:variable name="types" select="($a-fields[@tag = ('130', '240')], $a-fields[@tag = ('730')][@ind2='2'], $t-fields[@tag = ('700', '710', '711')][@ind2='2'])/../marc:datafield[@tag='380']/marc:subfield[@code='a']"/>
                                        <xsl:copy-of select="'* ' || normalize-space(string-join($titles, ' / ')) || (if (count($types) > 0) then '(' || string-join(distinct-values($types), ' / ') || ')' else (' ')) || current-grouping-key()"/>
                                        <xsl:value-of select="bib:newline()"/>
                                </xsl:for-each-group>
                        </xsl:otherwise>
                </xsl:choose>     
        </xsl:template>
        
        <xsl:template name="relatorcodes">
                <!-- Lister relatorkoder -->   
                <xsl:param name="collection" required="yes"/>
                <xsl:param name="format" required="yes"/>
                <xsl:copy-of
                        select="bib:header(('Oversikt over MARC 21 relator koder brukt i samlingen', 'sjekker bare feltene 100, 110, 111, 700, 710, 711'), $format)"/>
                <xsl:if test="not(/*//marc:datafield[@tag = ('100', '110', '111', '700', '710', '711')]/marc:subfield[@code = '4'][string-length(.) eq 3])">
                        <xsl:copy-of
                                select="bib:printasline('Finner ingen MARC 21 relator koder i $4', $format)"
                        />
                </xsl:if>
                <xsl:choose>
                        <xsl:when test="$format = 'fo'">
                                <fo:list-block provisional-distance-between-starts="20pt" provisional-label-separation="6pt">
                                <xsl:for-each-group
                                        select="/*//marc:datafield[@tag = ('100', '110', '111', '700', '710', '711')]/marc:subfield[@code = '4']"
                                        group-by="." >
                                        <xsl:sort select="current-grouping-key()"/>
                                        <xsl:if test="string-length(current-grouping-key()) eq 3">
                                                <fo:list-item>
                                                        <fo:list-item-label end-indent="label-end()">
                                                                <fo:block>
                                                                        <fo:inline>*</fo:inline>
                                                                </fo:block>
                                                        </fo:list-item-label>
                                                        <fo:list-item-body start-indent="body-start()">
                                                                <fo:block font-size="10pt" text-align="left">
                                                                        <xsl:copy-of
                                                                                select="current-grouping-key() || ' :  ' || count(current-group())"
                                                                        />
                                                                </fo:block>
                                                        </fo:list-item-body>
                                                </fo:list-item>
                                        </xsl:if>
                                </xsl:for-each-group>
                                </fo:list-block>
                        </xsl:when>
                        <xsl:otherwise>
                                <xsl:for-each-group
                                        select="/*//marc:datafield[@tag = ('100', '110', '111', '700', '710', '711')]/marc:subfield[@code = '4']"
                                        group-by="." >
                                        <xsl:sort select="current-grouping-key()"/>
                                        <xsl:if test="string-length(current-grouping-key()) eq 3">
                                                <xsl:copy-of
                                                        select="bib:printasline('* ' || string-join((current-grouping-key(), count(current-group())), '  : '), $format)"
                                                />
                                        </xsl:if>
                                </xsl:for-each-group>
                        </xsl:otherwise>
                </xsl:choose>
        </xsl:template>
        
        <xsl:template name="agenturis">
                <xsl:param name="collection" required="yes"/>
                <xsl:param name="format" required="yes"/>
                <xsl:copy-of
                        select="bib:header(('Oversikt over URI relasjonstyper for Agent brukt i samlingen', 'verdier som starter på http - sjekker feltene 100, 110, 111, 700, 710, 711'), $format)"/>
                
                <xsl:choose>
                        <xsl:when test="not(/*//marc:datafield[@tag = ('100', '110', '111', '700', '710', '711')][not(marc:subfield/@code = 't')]/marc:subfield[@code = '4'][starts-with(normalize-space(.), 'http')])">
                                <xsl:copy-of
                                        select="bib:printasline('* Finner ingen URI i $4 for innførsler på agent', $format)"
                                />
                        </xsl:when>
                        <xsl:otherwise>
                                <xsl:choose>
                                        <xsl:when test="$format = 'fo'">
                                                <fo:list-block provisional-distance-between-starts="20pt" provisional-label-separation="6pt">
                                                        <xsl:for-each-group
                                                                select="/*//marc:datafield[@tag = ('100', '110', '111', '700', '710', '711')][not(marc:subfield/@code = 't')]/marc:subfield[@code = '4']/normalize-space()"
                                                                group-by="." >
                                                                <xsl:sort select="current-grouping-key()"/>
                                                                <xsl:if test="starts-with(current-grouping-key(), 'http')">
                                                                        <xsl:variable name="label" select="document('rda.labels.rdf')/rdf:RDF/rdf:Description[@rdf:about=current-grouping-key()]/rdfs:label"/>
                                                                        <fo:list-item>
                                                                                <fo:list-item-label end-indent="label-end()">
                                                                                        <fo:block>
                                                                                                <fo:inline>*</fo:inline>
                                                                                        </fo:block>
                                                                                </fo:list-item-label>
                                                                                <fo:list-item-body start-indent="body-start()">
                                                                                        <fo:block font-size="10pt" text-align="left">
                                                                                                <xsl:copy-of
                                                                                                        select="bib:printasline(string-join((current-grouping-key() || ' (' || $label || ')', count(current-group())), '  : '), $format)"
                                                                                                />
                                                                                        </fo:block>
                                                                                </fo:list-item-body>
                                                                        </fo:list-item>
                                                                        
                                                                </xsl:if>
                                                        </xsl:for-each-group>
                                                </fo:list-block>
                                        </xsl:when>
                                        <xsl:otherwise>
                                                <xsl:for-each-group
                                                        select="/*//marc:datafield[@tag = ('100', '110', '111', '700', '710', '711')][not(marc:subfield/@code = 't')]/marc:subfield[@code = '4']/normalize-space()"
                                                        group-by="." >
                                                        <xsl:sort select="current-grouping-key()"/>
                                                        <xsl:if test="starts-with(current-grouping-key(), 'http')">
                                                                <xsl:variable name="label" select="document('rda.labels.rdf')/rdf:RDF/rdf:Description[@rdf:about=current-grouping-key()]/rdfs:label"/>
                                                                <xsl:copy-of
                                                                        select="bib:printasline('* ' || string-join((current-grouping-key() || ' (' || $label || ') : ' || count(current-group()))), $format)"
                                                                />
                                                        </xsl:if>
                                                </xsl:for-each-group>
                                        </xsl:otherwise>
                                </xsl:choose>
                        </xsl:otherwise>
                        
                </xsl:choose>


        </xsl:template>
        
        <xsl:template name="wortoworkrelationshiptypes">
                <xsl:param name="collection" required="yes"/>
                <xsl:param name="format" required="yes"/>
                <xsl:copy-of
                        select="bib:header(('Verk til verk RDA relasjonstyper i 7XX $4-subfelt + label fra RDA registry'), $format)"/>
                <xsl:choose>
                        <xsl:when test="not(/*//marc:datafield[@tag = ('700', '710', '711', '730', '758') and marc:subfield[(../@tag = ('700', '710', '711') and @code = 't') or (../@tag = ('730', '758'))] and @ind2 != '2' and (some $x in marc:subfield[@code = '4'] satisfies starts-with($x, 'http'))])">
                                <xsl:copy-of
                                        select="bib:printasline('Ser ut som dere mangler verk-til-verk relasjoner?', $format)"/>
                        </xsl:when>
                        <xsl:otherwise>
                                <xsl:choose>
                                        <xsl:when test="$format eq 'fo'">
                                                <fo:list-block provisional-distance-between-starts="20pt" provisional-label-separation="6pt">
                                                        <xsl:for-each-group
                                                                select="/*//marc:datafield[@tag = ('700', '710', '711', '730', '758') and marc:subfield[(../@tag = ('700', '710', '711') and @code = 't') or (../@tag = ('730', '758') ) ] and @ind2 != '2' and (some $x in marc:subfield[@code = '4'] satisfies starts-with($x, 'http'))]"
                                                                group-by="if (marc:subfield[@code = '4' and starts-with(., 'http')]) then marc:subfield[@code = '4' and starts-with(., 'http')]/normalize-space() else 'mangler $4 med URI'">
                                                                <xsl:sort select="current-grouping-key()"/>
                                                                <xsl:variable name="label" select="document('rda.labels.rdf')/rdf:RDF/rdf:Description[@rdf:about=current-grouping-key()]/rdfs:label"/>
                                                                <fo:list-item>
                                                                        <fo:list-item-label end-indent="label-end()">
                                                                                <fo:block>
                                                                                        <fo:inline>*</fo:inline>
                                                                                </fo:block>
                                                                        </fo:list-item-label>
                                                                        <fo:list-item-body start-indent="body-start()">
                                                                                <fo:block font-size="9pt" text-align="left">
                                                                                        <xsl:copy-of
                                                                                                select="bib:printasline(string-join((current-grouping-key() || ' (' || $label || ')', count(current-group())), '  : '), $format)"/>
                                                                                </fo:block>
                                                                                <!--<xsl:variable name="terms" select="distinct-values($collection//marc:datafield[@tag=('700', '710', '711', '730', '758')][some $x in marc:subfield[@code='4'] satisfies $x eq current-grouping-key()]/marc:subfield[@code = 'i'])"/>
                                                                                <xsl:if test="count($terms) > 0">
                                                                                        <fo:block font-size="10pt" text-align="left">
                                                                                                <xsl:copy-of
                                                                                                        select="bib:printasline('Termer brukt i $i: ' || string-join($terms, ', '), $format)"/>
                                                                                        </fo:block>
                                                                                </xsl:if>-->
                                                                        </fo:list-item-body>
                                                                </fo:list-item>
                                                                
                                                        </xsl:for-each-group>
                                                </fo:list-block>
                                        </xsl:when>
                                        <xsl:otherwise>
                                                <xsl:for-each-group
                                                        select="/*//marc:datafield[@tag = ('700', '710', '711', '730', '758') and marc:subfield[(../@tag = ('700', '710', '711') and @code = 't') or (../@tag = ('730', '758') ) ] and @ind2 != '2' and (some $x in marc:subfield[@code = '4'] satisfies starts-with($x, 'http'))]"
                                                        group-by="if (marc:subfield[@code = '4' and starts-with(., 'http')]) then marc:subfield[@code = '4' and starts-with(., 'http')]/normalize-space() else 'mangler $4 med URI'">
                    
                                                        <xsl:sort select="current-grouping-key()"/>
                                                        <xsl:variable name="label" select="document('rda.labels.rdf')/rdf:RDF/rdf:Description[@rdf:about = current-grouping-key()]/rdfs:label"/>
                                                        <xsl:copy-of
                                                                select="bib:printasline('* ' || string-join((current-grouping-key() || ' (' || string-join($label, ' xxx ') || ') : ' || count(current-group()))), $format)"/>
                                                </xsl:for-each-group>
                                                
                                        </xsl:otherwise>
                                </xsl:choose>
                        </xsl:otherwise>
                </xsl:choose>
        </xsl:template>  
        
        
        <xsl:template name="wortoworkrelationships">
                <xsl:param name="collection" required="yes"/>
                <xsl:param name="format" required="yes"/>
                <xsl:variable name="recordset" select="$collection/marc:record[marc:datafield[@tag=('130', '240')][marc:subfield/@code='1']]"/>
                <xsl:variable name="subset1" select="$recordset[marc:datafield[@tag = ('700', '710', '711')][@ind2 ne '2'][marc:subfield/@code = 't'][marc:subfield/@code = '1'][some $x in marc:subfield[@code = '4'] satisfies starts-with($x, 'http')]]"/>
                <xsl:variable name="subset2" select="$recordset[marc:datafield[@tag = ('730', '758')][@ind2 ne '2'][marc:subfield/@code = '1'][some $x in marc:subfield[@code = '4'] satisfies starts-with($x, 'http')]]"/>
                <xsl:variable name="subset3" select="$recordset[marc:datafield[@tag = ('600', '610', '611', '630', '800', '810', '811', '830')][marc:subfield/@code = '1']]"/>                
                <!--<xsl:variable name="subset4" select="$recordset[marc:datafield[@tag = ('700', '710', '711')][@ind2 eq '2'][marc:subfield/@code = 't'][marc:subfield/@code = '1']]"/>
                <xsl:variable name="subset5" select="$recordset[marc:datafield[@tag = ('730')][@ind2 eq '2'][marc:subfield/@code = '1']]"/>-->
                <xsl:variable name="result" select="$subset1 | $subset2 | $subset3"/>
                <xsl:copy-of
                        select="bib:header(('Lister alle verk til verk relasjoner i samlingen, inkl emne, serier (men ikke analytter)'), $format)"/>
                <xsl:choose> 
                        <xsl:when test="count($result) > 0">
                                <xsl:for-each select="$result">
                                        <xsl:variable name="recordid" select="if (marc:controlfield[@tag = '001']) then '001 = ' || marc:controlfield[@tag = '001'][1] 
                                                else if (marc:controlfield[@tag = '003']) then '003 = ' || marc:controlfield[@tag = '003'][1]
                                                else if (marc:datafield[@tag='020']/marc:subfield[@code='a']) then ('ISBN = ' || marc:datafield[@tag='020']/marc:subfield[@code='a'])[1]
                                                else 'Post som mangler 001, 003, 020'"/>
                                        <xsl:choose>
                                                <xsl:when test="./marc:datafield[@tag = '130']">
                                                        <xsl:copy-of select="bib:listheader(($recordid || ', ' || (marc:datafield[@tag = '130']/marc:subfield[@code='a'])[1]/normalize-space() || ' / ' || string-join(marc:datafield[@tag = '380']/marc:subfield[@code='a'], ', ')), $format)"/>
                                                </xsl:when>
                                                <xsl:when test="./marc:datafield[@tag = '240']">
                                                        <xsl:copy-of select="bib:listheader(($recordid || ', ' || (marc:datafield[@tag = '240']/marc:subfield[@code='a'])[1]/normalize-space() || ' / ' || (marc:datafield[@tag = '100']/marc:subfield[@code='a'])[1]/normalize-space() || ' / ' || string-join(marc:datafield[@tag = '380']/marc:subfield[@code='a'], ', ')), $format)"/>
                                                </xsl:when>
                                                <xsl:otherwise>
                                                        <xsl:copy-of select="bib:listheader($recordid || ', ' || 'Ikke noe target i 130/240 som enten betyr at feltlenking fra 700 er brukt, eller at noe er feil ', $format)"/>
                                                </xsl:otherwise>
                                        </xsl:choose>
                                        
                                        <xsl:variable name="result1">
                                                <xsl:sequence>
                                                <xsl:for-each select="./marc:datafield[@tag=('700', '710', '711') and @ind2 ne '2'][marc:subfield/@code='1'][marc:subfield/@code='t'][some $x in marc:subfield[@code = '4'] satisfies starts-with($x, 'http')]">
                                                        <xsl:variable name="reluris" select="./marc:subfield[@code='4'][starts-with(., 'http')]"/>
                                                        <xsl:variable name="target" select="./marc:subfield[@code='t'] || ' / ' || ./marc:subfield[@code='a']"/>
                                                        <xsl:variable name="tagname" select="@tag"/>
                                                        <xsl:for-each select="$reluris">
                                                                <xsl:variable name="uri" select="normalize-space(.)"/>
                                                                <xsl:variable name="label" select="document('rda.labels.rdf')/rdf:RDF/rdf:Description[@rdf:about eq $uri]/rdfs:label"/>                                                                        
                                                                <label>
                                                                        <xsl:value-of select="$uri || ' (' || $label || ') -> ' || $target || ' (' || $tagname ||')'"/>
                                                                </label> 
                                                        </xsl:for-each>
                                                </xsl:for-each>
                                                </xsl:sequence>
                                        </xsl:variable>
                                        <xsl:variable name="result2">
                                                <xsl:sequence>
                                                <xsl:for-each select="./marc:datafield[@tag=('730') and @ind2 ne '2'][marc:subfield/@code='1'][some $x in marc:subfield[@code = '4'] satisfies starts-with($x, 'http')]">
                                                        <xsl:variable name="reluris" select="./marc:subfield[@code='4'][starts-with(., 'http')]"/>
                                                        <xsl:variable name="target" select="./marc:subfield[@code='t'] || ' / ' || ./marc:subfield[@code='a']"/>
                                                        <xsl:variable name="tagname" select="@tag"/>
                                                        <xsl:for-each select="$reluris">
                                                                <xsl:variable name="uri" select="normalize-space(.)"/>
                                                                <xsl:variable name="label" select="document('rda.labels.rdf')/rdf:RDF/rdf:Description[@rdf:about eq $uri]/rdfs:label"/>                                                                        
                                                                <label>
                                                                        <xsl:value-of select="$uri || ' (' || $label || ') -> ' || $target || ' (' || $tagname ||')'"/>
                                                                </label>
                                                        </xsl:for-each>
                                                </xsl:for-each>
                                                </xsl:sequence>
                                        </xsl:variable>
                                        <xsl:variable name="result3">
                                                <xsl:sequence>
                                                <xsl:for-each select="./marc:datafield[@tag=('758')][marc:subfield/@code='1'][some $x in marc:subfield[@code = '4'] satisfies starts-with($x, 'http')]">
                                                        <xsl:variable name="reluris" select="./marc:subfield[@code='4'][starts-with(., 'http')]"/>
                                                        <xsl:variable name="target" select="./marc:subfield[@code='a']"/>
                                                        <xsl:variable name="tagname" select="@tag"/>
                                                        <xsl:for-each select="$reluris">
                                                                <xsl:variable name="uri" select="normalize-space(.)"/>
                                                                <xsl:variable name="label" select="document('rda.labels.rdf')/rdf:RDF/rdf:Description[@rdf:about eq $uri]/rdfs:label"/>                                                                        
                                                                <label>
                                                                        <xsl:value-of select="$uri || ' (' || $label || ') -> ' || $target || ' (' || $tagname || ')'"/>
                                                                </label>
                                                        </xsl:for-each>
                                                </xsl:for-each>
                                                </xsl:sequence>
                                        </xsl:variable>
                                        <xsl:variable name="result4">
                                                <xsl:sequence>
                                                        <xsl:for-each select="./marc:datafield[@tag=('600', '610', '611')][marc:subfield/@code='1'][not(marc:subfield/@code='t')]">
                                                                <xsl:variable name="target" select="./marc:subfield[@code='a']"/>
                                                                <label>
                                                                        <xsl:value-of select="'has subject agent' || ' -> ' || $target || ' (' || @tag || ')'"/>
                                                                </label>                                                                
                                                        </xsl:for-each>
                                                        <xsl:for-each select="./marc:datafield[@tag=('600', '610', '611')][marc:subfield/@code='1'][marc:subfield/@code='t']">
                                                                <xsl:variable name="target" select="./marc:subfield[@code='t'] || ' / ' || ./marc:subfield[@code='a']"/>
                                                                <label>
                                                                        <xsl:value-of select="'http://rdaregistry.info/Elements/w/P10257 (has subject work)' || ' -> ' || $target || ' (' || @tag || ')'"/>
                                                                </label>                                                                
                                                        </xsl:for-each>
                                                        <xsl:for-each select="./marc:datafield[@tag=('630')][marc:subfield/@code='1']">
                                                                <xsl:variable name="target" select="./marc:subfield[@code='a']"/>
                                                                <label>
                                                                        <xsl:value-of select="'http://rdaregistry.info/Elements/w/P10257 (has subject work)' || ' -> ' || $target || ' (' || @tag ||')'"/>
                                                                </label>                                                                
                                                        </xsl:for-each>
                                                </xsl:sequence>
                                        </xsl:variable>
                                        <xsl:variable name="result5">
                                                <xsl:sequence>
                                                        <xsl:for-each select="./marc:datafield[@tag=('800', '810', '811')][marc:subfield/@code='1']">
                                                                <xsl:variable name="target" select="./marc:subfield[@code='t'][1] || ' / ' || ./marc:subfield[@code='a']"/>
                                                                <label>
                                                                        <xsl:value-of select="'http://rdaregistry.info/Elements/w/P10019 (is part of work)' || ' -> ' || $target || ' (' || @tag || ')'"/>
                                                                </label>                                                                
                                                        </xsl:for-each>
                                                        <xsl:for-each select="./marc:datafield[@tag=('830')][marc:subfield/@code='1']">
                                                                <xsl:variable name="target" select="./marc:subfield[@code='a']"/>
                                                                <label>
                                                                        <xsl:value-of select="'http://rdaregistry.info/Elements/w/P10019 (is part of work)' || ' -> ' || $target || ' (' || @tag || ')'"/>
                                                                </label>                                                                
                                                        </xsl:for-each>
                                                </xsl:sequence>
                                        </xsl:variable>
                                        <!--<xsl:variable name="result6">
                                                <xsl:sequence>
                                                        <xsl:for-each select="./marc:datafield[@tag=('700')][@ind2='2'][marc:subfield/@code='1'][marc:subfield/@code='t']">
                                                                <xsl:variable name="target" select="./marc:subfield[@code='t'][1] || ' / ' || ./marc:subfield[@code='a']"/>
                                                                <label>
                                                                        <xsl:value-of select="'is part of work' || ' -> ' || $target || ' (' || @tag || ')'"/>
                                                                </label>                                                                
                                                        </xsl:for-each>
                                                        <xsl:for-each select="./marc:datafield[@tag=('830')][marc:subfield/@code='1']">
                                                                <xsl:variable name="target" select="./marc:subfield[@code='a']"/>
                                                                <label>
                                                                        <xsl:value-of select="'is part of work' || ' -> ' || $target || ' (' || @tag || ')'"/>
                                                                </label>                                                                
                                                        </xsl:for-each>
                                                </xsl:sequence>
                                        </xsl:variable>-->
                                        <xsl:copy-of select="bib:list(distinct-values(($result1/label, $result2/label, $result3/label, $result4/label, $result5/label)), $format)"/>
                                </xsl:for-each>
                        </xsl:when>
                        <xsl:otherwise>
                                <xsl:copy-of
                                        select="bib:printasline('Ser ut som dere mangler slike relasjoner?', $format)"/>
                        </xsl:otherwise>
                </xsl:choose>
        </xsl:template> 
        
        <xsl:template name="duplicateuris">
                <xsl:param name="collection" required="yes"/>
                <xsl:param name="format" required="yes"/>
                <xsl:variable name="authors" select="$collection/marc:record/marc:datafield[@tag = ('100', '110', '111', '600', '610', '611', '700', '710', '711') and not(marc:subfield[@code='t'])]/marc:subfield[@code='1' and starts-with(normalize-space(.), 'http')]"/>
                <xsl:variable name="mainentryworks" select="$collection/marc:record/marc:datafield[@tag = ('130', '240', '630', '730', '830')]/marc:subfield[@code='1' and starts-with(normalize-space(.), 'http')]"/>
                <xsl:variable name="subjectandaddedworks" select="$collection/marc:record/marc:datafield[@tag = ('600', '610', '611', '700', '710', '711') and marc:subfield[@code='t']]/marc:subfield[@code='1' and starts-with(normalize-space(.), 'http')]"/>
                <xsl:variable name="seriesworks" select="$collection/marc:record/marc:datafield[@tag = ('800', '810', '811')]/marc:subfield[@code='1' and starts-with(normalize-space(.), 'http')]"/>
                <xsl:variable name="works" select="$mainentryworks | $subjectandaddedworks | $seriesworks"/>
               <xsl:if test="$authors[. = $works]">
                        <xsl:copy-of
                                select="bib:header(('URIer som brukes til både verk og agent', 'kan være fordi dere bruker feil URI, eller pga hvordan subfelt er brukt') , $format)"/>
                        <xsl:for-each select="distinct-values($authors[. = $works])">
                                <xsl:copy-of select="bib:printasline(., $format)"/>
                        </xsl:for-each>
                </xsl:if>
        </xsl:template>
        
</xsl:stylesheet>

