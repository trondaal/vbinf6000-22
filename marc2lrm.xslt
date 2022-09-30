<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:frbrizer="http://idi.ntnu.no/frbrizer/"
                 xmlns:xs="http://www.w3.org/2001/XMLSchema"
                 xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                 version="3.0">
   <xsl:param name="debug" as="xs:boolean" select="false()"/>
   <xsl:param name="include_MARC001_in_entityrecord"
               as="xs:boolean"
               select="false()"/>
   <xsl:param name="include_MARC001_in_controlfield"
               as="xs:boolean"
               select="false()"/>
   <xsl:param name="include_MARC001_in_subfield" as="xs:boolean" select="false()"/>
   <xsl:param name="include_MARC001_in_relationships"
               as="xs:boolean"
               select="false()"/>
   <xsl:param name="include_anchorvalues" as="xs:boolean" select="false()"/>
   <xsl:param name="include_templateinfo" as="xs:boolean" select="false()"/>
   <xsl:param name="include_sourceinfo" as="xs:boolean" select="false()"/>
   <xsl:param name="include_keyvalues" as="xs:boolean" select="false()"/>
   <xsl:param name="include_internal_key" as="xs:boolean" select="false()"/>
   <xsl:param name="include_counters" as="xs:boolean" select="false()"/>
   <xsl:param name="merge" as="xs:boolean" select="true()"/>
   <xsl:param name="rdf" as="xs:boolean" select="true()"/>
   <xsl:param name="ignore_indicators_in_merge" as="xs:boolean" select="true()"/>
   <xsl:param name="include_id_as_element" as="xs:boolean" select="false()"/>
   <xsl:param name="include_missing_reverse_relationships"
               as="xs:boolean"
               select="true()"/>
   <xsl:param name="userdefined" as="xs:boolean" select="false()"/>
   <xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes"/>
   <xsl:template match="/*:collection">
      <xsl:variable name="entity-collection">
         <xsl:copy>
            <xsl:namespace name="mads" select="'http://www.loc.gov/mads/rdf/v1#'"/>
            <xsl:namespace name="mmmm" select="'http://www.loc.gov/MARC21/slim/'"/>
            <xsl:namespace name="rdaad" select="'http://rdaregistry.info/Elements/a/datatype/'"/>
            <xsl:namespace name="rdaao" select="'http://rdaregistry.info/Elements/a/object/'"/>
            <xsl:namespace name="rdac" select="'http://rdaregistry.info/Elements/c/'"/>
            <xsl:namespace name="rdaco"
                            select="'http://rdaregistry.info/termList/RDAContentType/'"/>
            <xsl:namespace name="rdact"
                            select="'http://rdaregistry.info/termList/RDACarrierType/'"/>
            <xsl:namespace name="rdaed" select="'http://rdaregistry.info/Elements/e/datatype/'"/>
            <xsl:namespace name="rdaeo" select="'http://rdaregistry.info/Elements/e/object/'"/>
            <xsl:namespace name="rdamd" select="'http://rdaregistry.info/Elements/m/datatype/'"/>
            <xsl:namespace name="rdamo" select="'http://rdaregistry.info/Elements/m/object/'"/>
            <xsl:namespace name="rdamt" select="'http://rdaregistry.info/termList/RDAMediaType/'"/>
            <xsl:namespace name="rdat" select="'http://rdaregistry.info/termList/'"/>
            <xsl:namespace name="rdawd" select="'http://rdaregistry.info/Elements/w/datatype/'"/>
            <xsl:namespace name="rdawo" select="'http://rdaregistry.info/Elements/w/object/'"/>
            <xsl:namespace name="rdaxd" select="'http://rdaregistry.info/Elements/x/datatype/'"/>
            <xsl:namespace name="rdfs" select="'http://www.w3.org/2000/01/rdf-schema#'"/>
            <xsl:namespace name="skos" select="'http://www.w3.org/2004/02/skos/core#'"/>
            <xsl:namespace name="xml" select="'http://www.w3.org/XML/1998/namespace'"/>
            <xsl:call-template name="copy-attributes"/>
            <xsl:for-each select="*:record">
               <xsl:call-template name="create-record-set"/>
            </xsl:for-each>
         </xsl:copy>
      </xsl:variable>
      <xsl:variable name="entity-collection-merged">
         <xsl:choose>
            <xsl:when test="$merge">
               <xsl:apply-templates select="$entity-collection" mode="merge"/>
            </xsl:when>
            <xsl:otherwise>
               <xsl:copy-of select="$entity-collection"/>
            </xsl:otherwise>
         </xsl:choose>
      </xsl:variable>
      <xsl:variable name="entity-collection-userdefined">
         <xsl:choose>
            <xsl:when test="$userdefined">
               <xsl:apply-templates select="$entity-collection-merged" mode="userdefined"/>
            </xsl:when>
            <xsl:otherwise>
               <xsl:copy-of select="$entity-collection-merged"/>
            </xsl:otherwise>
         </xsl:choose>
      </xsl:variable>
      <xsl:choose>
         <xsl:when test="$rdf">
            <xsl:apply-templates select="$entity-collection-userdefined" mode="rdfify"/>
         </xsl:when>
         <xsl:otherwise>
            <xsl:copy-of select="$entity-collection-userdefined"/>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:template>
   <xsl:template match="*:record" name="create-record-set">
      <xsl:variable name="step1">
         <frbrizer:record-set>
            <xsl:call-template name="MARC380"/>
            <xsl:call-template name="MARC336"/>
            <xsl:call-template name="MARC337"/>
            <xsl:call-template name="MARC338"/>
            <xsl:call-template name="MARC041"/>
            <xsl:call-template name="MARC041additional"/>
            <xsl:call-template name="MARC008language"/>
            <xsl:call-template name="MARC21-100700Person"/>
            <xsl:call-template name="MARC21-130240-Work"/>
            <xsl:call-template name="MARC21-130240-Expression"/>
            <xsl:call-template name="MARC21-245-Manifestation"/>
            <xsl:call-template name="MARC21-600-Person"/>
            <xsl:call-template name="MARC21-6XX-Work"/>
            <xsl:call-template name="MARC21-700-Related-Work"/>
            <xsl:call-template name="MARC21-700-Work-Analytical"/>
            <xsl:call-template name="MARC21-700-Expression-Analytical"/>
            <xsl:call-template name="MARC21-758-Related-Work"/>
            <xsl:call-template name="MARC21-8XX-Work-Series"/>
         </frbrizer:record-set>
      </xsl:variable>
      <xsl:variable name="step2">
         <xsl:apply-templates select="$step1" mode="create-inverse-relationships"/>
      </xsl:variable>
      <xsl:variable name="step3">
         <xsl:apply-templates select="$step2" mode="create-keys"/>
      </xsl:variable>
      <xsl:copy-of select="$step3//*:record"/>
   </xsl:template>
   <xsl:template name="MARC008language">
      <xsl:variable name="this_template_name" select="'MARC008language'"/>
      <xsl:variable name="tag" as="xs:string" select="'008'"/>
      <xsl:variable name="record" select="."/>
      <xsl:variable name="marcid" select="*:controlfield[@tag='001']"/>
      <xsl:for-each select="node()[@tag=('008')][string-length(.) eq 40 and matches(substring(., 36, 3), '[a-z][a-z][a-z]')]">
         <xsl:variable name="this_field"
                        select="(ancestor-or-self::*:datafield, ancestor-or-self::*:controlfield)"/>
         <xsl:variable name="this"
                        select="(ancestor-or-self::*:datafield, ancestor-or-self::*:controlfield)"/>
         <xsl:variable name="anchor_field"
                        select="(ancestor-or-self::*:datafield, ancestor-or-self::*:controlfield)"/>
         <xsl:variable name="anchor"
                        as="xs:string"
                        select="(ancestor-or-self::*:datafield, ancestor-or-self::*:controlfield)"/>
         <xsl:variable name="this_field_position"
                        as="xs:string"
                        select="string(position())"/>
         <xsl:element name="{name(ancestor-or-self::*:record)}"
                       namespace="{namespace-uri(ancestor-or-self::*:record)}">
            <xsl:attribute name="id"
                            select="string-join(($record/@id,$this_template_name,$tag,$this_field_position), ':')"/>
            <xsl:attribute name="type" select="'http://www.w3.org/2004/02/skos/core#Concept'"/>
            <xsl:attribute name="templatename" select="$this_template_name"/>
            <xsl:for-each select="$record/*:controlfield[@tag='008'][$this_field_position]">
               <xsl:copy>
                  <xsl:call-template name="copy-content">
                     <xsl:with-param name="type" select="'http://www.w3.org/2000/01/rdf-schema#label'"/>
                     <xsl:with-param name="select" select="substring(., 36, 3)"/>
                     <xsl:with-param name="marcid" select="$marcid"/>
                  </xsl:call-template>
               </xsl:copy>
            </xsl:for-each>
         </xsl:element>
      </xsl:for-each>
   </xsl:template>
   <xsl:template name="MARC041">
      <xsl:variable name="this_template_name" select="'MARC041'"/>
      <xsl:variable name="tag" as="xs:string" select="'041'"/>
      <xsl:variable name="code" as="xs:string" select="'a, d'"/>
      <xsl:variable name="record" select="."/>
      <xsl:variable name="marcid" select="*:controlfield[@tag='001']"/>
      <xsl:for-each select="node()[@tag=('041')]">
         <xsl:variable name="this_field"
                        select="(ancestor-or-self::*:datafield, ancestor-or-self::*:controlfield)"/>
         <xsl:variable name="this"
                        select="(ancestor-or-self::*:datafield, ancestor-or-self::*:controlfield)"/>
         <xsl:variable name="anchor_field"
                        select="(ancestor-or-self::*:datafield, ancestor-or-self::*:controlfield)"/>
         <xsl:variable name="anchor"
                        as="xs:string"
                        select="(ancestor-or-self::*:datafield, ancestor-or-self::*:controlfield)"/>
         <xsl:variable name="this_field_position"
                        as="xs:string"
                        select="string(position())"/>
         <xsl:for-each select="node()[@code=('a','d')]">
            <xsl:variable name="this_subfield" select="(ancestor-or-self::*:subfield)"/>
            <xsl:variable name="anchor_subfield" select="(ancestor-or-self::*:subfield)"/>
            <xsl:variable name="this_subfield_code"
                           as="xs:string"
                           select="$this_subfield/@code"/>
            <xsl:variable name="anchor_subfield_code"
                           as="xs:string"
                           select="$this_subfield/@code"/>
            <xsl:variable name="this_subfield_position"
                           as="xs:string"
                           select="string(position())"/>
            <xsl:element name="{name(ancestor-or-self::*:record)}"
                          namespace="{namespace-uri(ancestor-or-self::*:record)}">
               <xsl:attribute name="id"
                               select="string-join(($record/@id,$this_template_name,$tag,$this_subfield_code,$this_field_position,$this_subfield_position), ':')"/>
               <xsl:attribute name="type" select="'http://www.w3.org/2004/02/skos/core#Concept'"/>
               <xsl:attribute name="templatename" select="$this_template_name"/>
               <xsl:for-each select="$record/*:datafield[@tag='041'][generate-id(.) = generate-id($anchor_field)][*:subfield/@code = ('a','d')]">
                  <xsl:copy>
                     <xsl:call-template name="copy-attributes"/>
                     <xsl:for-each select="*:subfield[@code = ('a','d')]">
                        <xsl:if test="@code = 'a' and generate-id(.) = generate-id($anchor_subfield)">
                           <xsl:copy>
                              <xsl:call-template name="copy-content">
                                 <xsl:with-param name="type"
                                                  select="'http://www.w3.org/2004/02/skos/core#subjectIndicator'"/>
                                 <xsl:with-param name="select" select="."/>
                              </xsl:call-template>
                           </xsl:copy>
                        </xsl:if>
                        <xsl:if test="@code = 'd' and generate-id(.) = generate-id($anchor_subfield)">
                           <xsl:copy>
                              <xsl:call-template name="copy-content">
                                 <xsl:with-param name="type"
                                                  select="'http://www.w3.org/2004/02/skos/core#subjectIndicator'"/>
                                 <xsl:with-param name="select" select="."/>
                              </xsl:call-template>
                           </xsl:copy>
                        </xsl:if>
                     </xsl:for-each>
                  </xsl:copy>
               </xsl:for-each>
            </xsl:element>
         </xsl:for-each>
      </xsl:for-each>
   </xsl:template>
   <xsl:template name="MARC041additional">
      <xsl:variable name="this_template_name" select="'MARC041additional'"/>
      <xsl:variable name="tag" as="xs:string" select="'041'"/>
      <xsl:variable name="code"
                     as="xs:string"
                     select="'b, e, f, g, i, j, k, l, m, n, p, q, r, t'"/>
      <xsl:variable name="record" select="."/>
      <xsl:variable name="marcid" select="*:controlfield[@tag='001']"/>
      <xsl:for-each select="node()[@tag=('041')]">
         <xsl:variable name="this_field"
                        select="(ancestor-or-self::*:datafield, ancestor-or-self::*:controlfield)"/>
         <xsl:variable name="this"
                        select="(ancestor-or-self::*:datafield, ancestor-or-self::*:controlfield)"/>
         <xsl:variable name="anchor_field"
                        select="(ancestor-or-self::*:datafield, ancestor-or-self::*:controlfield)"/>
         <xsl:variable name="anchor"
                        as="xs:string"
                        select="(ancestor-or-self::*:datafield, ancestor-or-self::*:controlfield)"/>
         <xsl:variable name="this_field_position"
                        as="xs:string"
                        select="string(position())"/>
         <xsl:for-each select="node()[@code=('b','e','f','g','i','j','k','l','m','n','p','q','r','t')]">
            <xsl:variable name="this_subfield" select="(ancestor-or-self::*:subfield)"/>
            <xsl:variable name="anchor_subfield" select="(ancestor-or-self::*:subfield)"/>
            <xsl:variable name="this_subfield_code"
                           as="xs:string"
                           select="$this_subfield/@code"/>
            <xsl:variable name="anchor_subfield_code"
                           as="xs:string"
                           select="$this_subfield/@code"/>
            <xsl:variable name="this_subfield_position"
                           as="xs:string"
                           select="string(position())"/>
            <xsl:element name="{name(ancestor-or-self::*:record)}"
                          namespace="{namespace-uri(ancestor-or-self::*:record)}">
               <xsl:attribute name="id"
                               select="string-join(($record/@id,$this_template_name,$tag,$this_subfield_code,$this_field_position,$this_subfield_position), ':')"/>
               <xsl:attribute name="type" select="'http://www.w3.org/2004/02/skos/core#Concept'"/>
               <xsl:attribute name="templatename" select="$this_template_name"/>
               <xsl:for-each select="$record/*:datafield[@tag='041'][generate-id(.) = generate-id($anchor_field)][*:subfield/@code = ('b','e','f','g','i','j','k','l','m','n','p','q','r','t')]">
                  <xsl:copy>
                     <xsl:call-template name="copy-attributes"/>
                     <xsl:for-each select="*:subfield[@code = ('b','e','f','g','i','j','k','l','m','n','p','q','r','t')]">
                        <xsl:if test="@code = 'b' and generate-id(.) = generate-id($anchor_subfield)">
                           <xsl:copy>
                              <xsl:call-template name="copy-content">
                                 <xsl:with-param name="type"
                                                  select="'http://www.w3.org/2004/02/skos/core#subjectIndicator'"/>
                                 <xsl:with-param name="select" select="."/>
                              </xsl:call-template>
                           </xsl:copy>
                        </xsl:if>
                        <xsl:if test="@code = 'e' and generate-id(.) = generate-id($anchor_subfield)">
                           <xsl:copy>
                              <xsl:call-template name="copy-content">
                                 <xsl:with-param name="type"
                                                  select="'http://www.w3.org/2004/02/skos/core#subjectIndicator'"/>
                                 <xsl:with-param name="select" select="."/>
                              </xsl:call-template>
                           </xsl:copy>
                        </xsl:if>
                        <xsl:if test="@code = 'f' and generate-id(.) = generate-id($anchor_subfield)">
                           <xsl:copy>
                              <xsl:call-template name="copy-content">
                                 <xsl:with-param name="type"
                                                  select="'http://www.w3.org/2004/02/skos/core#subjectIndicator'"/>
                                 <xsl:with-param name="select" select="."/>
                              </xsl:call-template>
                           </xsl:copy>
                        </xsl:if>
                        <xsl:if test="@code = 'g' and generate-id(.) = generate-id($anchor_subfield)">
                           <xsl:copy>
                              <xsl:call-template name="copy-content">
                                 <xsl:with-param name="type"
                                                  select="'http://www.w3.org/2004/02/skos/core#subjectIndicator'"/>
                                 <xsl:with-param name="select" select="."/>
                              </xsl:call-template>
                           </xsl:copy>
                        </xsl:if>
                        <xsl:if test="@code = 'i' and generate-id(.) = generate-id($anchor_subfield)">
                           <xsl:copy>
                              <xsl:call-template name="copy-content">
                                 <xsl:with-param name="type"
                                                  select="'http://www.w3.org/2004/02/skos/core#subjectIndicator'"/>
                                 <xsl:with-param name="select" select="."/>
                              </xsl:call-template>
                           </xsl:copy>
                        </xsl:if>
                        <xsl:if test="@code = 'j' and generate-id(.) = generate-id($anchor_subfield)">
                           <xsl:copy>
                              <xsl:call-template name="copy-content">
                                 <xsl:with-param name="type"
                                                  select="'http://www.w3.org/2004/02/skos/core#subjectIndicator'"/>
                                 <xsl:with-param name="select" select="."/>
                              </xsl:call-template>
                           </xsl:copy>
                        </xsl:if>
                        <xsl:if test="@code = 'k' and generate-id(.) = generate-id($anchor_subfield)">
                           <xsl:copy>
                              <xsl:call-template name="copy-content">
                                 <xsl:with-param name="type"
                                                  select="'http://www.w3.org/2004/02/skos/core#subjectIndicator'"/>
                                 <xsl:with-param name="select" select="."/>
                              </xsl:call-template>
                           </xsl:copy>
                        </xsl:if>
                        <xsl:if test="@code = 'l' and generate-id(.) = generate-id($anchor_subfield)">
                           <xsl:copy>
                              <xsl:call-template name="copy-content">
                                 <xsl:with-param name="type"
                                                  select="'http://www.w3.org/2004/02/skos/core#subjectIndicator'"/>
                                 <xsl:with-param name="select" select="."/>
                              </xsl:call-template>
                           </xsl:copy>
                        </xsl:if>
                        <xsl:if test="@code = 'm' and generate-id(.) = generate-id($anchor_subfield)">
                           <xsl:copy>
                              <xsl:call-template name="copy-content">
                                 <xsl:with-param name="type"
                                                  select="'http://www.w3.org/2004/02/skos/core#subjectIndicator'"/>
                                 <xsl:with-param name="select" select="."/>
                              </xsl:call-template>
                           </xsl:copy>
                        </xsl:if>
                        <xsl:if test="@code = 'n' and generate-id(.) = generate-id($anchor_subfield)">
                           <xsl:copy>
                              <xsl:call-template name="copy-content">
                                 <xsl:with-param name="type"
                                                  select="'http://www.w3.org/2004/02/skos/core#subjectIndicator'"/>
                                 <xsl:with-param name="select" select="."/>
                              </xsl:call-template>
                           </xsl:copy>
                        </xsl:if>
                        <xsl:if test="@code = 'p' and generate-id(.) = generate-id($anchor_subfield)">
                           <xsl:copy>
                              <xsl:call-template name="copy-content">
                                 <xsl:with-param name="type"
                                                  select="'http://www.w3.org/2004/02/skos/core#subjectIndicator'"/>
                                 <xsl:with-param name="select" select="."/>
                              </xsl:call-template>
                           </xsl:copy>
                        </xsl:if>
                        <xsl:if test="@code = 'q' and generate-id(.) = generate-id($anchor_subfield)">
                           <xsl:copy>
                              <xsl:call-template name="copy-content">
                                 <xsl:with-param name="type"
                                                  select="'http://www.w3.org/2004/02/skos/core#subjectIndicator'"/>
                                 <xsl:with-param name="select" select="."/>
                              </xsl:call-template>
                           </xsl:copy>
                        </xsl:if>
                        <xsl:if test="@code = 'r' and generate-id(.) = generate-id($anchor_subfield)">
                           <xsl:copy>
                              <xsl:call-template name="copy-content">
                                 <xsl:with-param name="type"
                                                  select="'http://www.w3.org/2004/02/skos/core#subjectIndicator'"/>
                                 <xsl:with-param name="select" select="."/>
                              </xsl:call-template>
                           </xsl:copy>
                        </xsl:if>
                        <xsl:if test="@code = 't' and generate-id(.) = generate-id($anchor_subfield)">
                           <xsl:copy>
                              <xsl:call-template name="copy-content">
                                 <xsl:with-param name="type"
                                                  select="'http://www.w3.org/2004/02/skos/core#subjectIndicator'"/>
                                 <xsl:with-param name="select" select="."/>
                              </xsl:call-template>
                           </xsl:copy>
                        </xsl:if>
                     </xsl:for-each>
                  </xsl:copy>
               </xsl:for-each>
            </xsl:element>
         </xsl:for-each>
      </xsl:for-each>
   </xsl:template>
   <xsl:template name="MARC21-100700Person">
      <xsl:variable name="this_template_name" select="'MARC21-100700Person'"/>
      <xsl:variable name="tag" as="xs:string" select="'100, 110, 111, 700, 710, 711'"/>
      <xsl:variable name="code" as="xs:string" select="'4'"/>
      <xsl:variable name="record" select="."/>
      <xsl:variable name="marcid" select="*:controlfield[@tag='001']"/>
      <xsl:for-each select="node()[@tag=('100','110','111','700','710','711')][exists(*:subfield[@code = '1']/starts-with(., 'http')) and not(*:subfield/@code = 't')]">
         <xsl:variable name="this_field"
                        select="(ancestor-or-self::*:datafield, ancestor-or-self::*:controlfield)"/>
         <xsl:variable name="this"
                        select="(ancestor-or-self::*:datafield, ancestor-or-self::*:controlfield)"/>
         <xsl:variable name="anchor_field"
                        select="(ancestor-or-self::*:datafield, ancestor-or-self::*:controlfield)"/>
         <xsl:variable name="anchor"
                        as="xs:string"
                        select="(ancestor-or-self::*:datafield, ancestor-or-self::*:controlfield)"/>
         <xsl:variable name="this_field_position"
                        as="xs:string"
                        select="string(position())"/>
         <xsl:for-each select="node()[@code=('4')][starts-with(., 'http')]">
            <xsl:variable name="this_subfield" select="(ancestor-or-self::*:subfield)"/>
            <xsl:variable name="anchor_subfield" select="(ancestor-or-self::*:subfield)"/>
            <xsl:variable name="this_subfield_code"
                           as="xs:string"
                           select="$this_subfield/@code"/>
            <xsl:variable name="anchor_subfield_code"
                           as="xs:string"
                           select="$this_subfield/@code"/>
            <xsl:variable name="this_subfield_position"
                           as="xs:string"
                           select="string(position())"/>
            <xsl:element name="{name(ancestor-or-self::*:record)}"
                          namespace="{namespace-uri(ancestor-or-self::*:record)}">
               <xsl:attribute name="id"
                               select="string-join(($record/@id,$this_template_name,$tag,$this_subfield_code,$this_field_position,$this_subfield_position), ':')"/>
               <xsl:attribute name="type" select="'http://rdaregistry.info/Elements/c/C10002'"/>
               <xsl:attribute name="templatename" select="$this_template_name"/>
               <xsl:for-each select="$record/*:datafield[@tag='100'][. eq $this_field][*:subfield/@code = ('a','d','1')]">
                  <xsl:copy>
                     <xsl:call-template name="copy-attributes"/>
                     <xsl:for-each select="*:subfield[@code = ('a','d','1')]">
                        <xsl:if test="@code = 'a'">
                           <xsl:copy>
                              <xsl:call-template name="copy-content">
                                 <xsl:with-param name="type" select="'http://www.w3.org/2000/01/rdf-schema#label'"/>
                                 <xsl:with-param name="select" select="frbrizer:trim(.)"/>
                              </xsl:call-template>
                           </xsl:copy>
                        </xsl:if>
                        <xsl:if test="@code = 'a'">
                           <xsl:copy>
                              <xsl:call-template name="copy-content">
                                 <xsl:with-param name="type"
                                                  select="'http://rdaregistry.info/Elements/a/datatype/P50385'"/>
                                 <xsl:with-param name="select" select="frbrizer:trim(.)"/>
                              </xsl:call-template>
                           </xsl:copy>
                        </xsl:if>
                        <xsl:if test="@code = 'd'">
                           <xsl:copy>
                              <xsl:call-template name="copy-content">
                                 <xsl:with-param name="type"
                                                  select="'http://rdaregistry.info/Elements/a/datatype/P50339'"/>
                                 <xsl:with-param name="select" select="frbrizer:trim(.)"/>
                              </xsl:call-template>
                           </xsl:copy>
                        </xsl:if>
                        <xsl:if test="@code = '1'">
                           <xsl:copy>
                              <xsl:call-template name="copy-content">
                                 <xsl:with-param name="type"
                                                  select="'http://rdaregistry.info/Elements/x/datatype/P00018'"/>
                                 <xsl:with-param name="select" select="."/>
                              </xsl:call-template>
                           </xsl:copy>
                        </xsl:if>
                     </xsl:for-each>
                  </xsl:copy>
               </xsl:for-each>
               <xsl:for-each select="$record/*:datafield[@tag='110'][. eq $this_field][*:subfield/@code = ('a','d','1')]">
                  <xsl:copy>
                     <xsl:call-template name="copy-attributes"/>
                     <xsl:for-each select="*:subfield[@code = ('a','d','1')]">
                        <xsl:if test="@code = 'a'">
                           <xsl:copy>
                              <xsl:call-template name="copy-content">
                                 <xsl:with-param name="type" select="'http://www.w3.org/2000/01/rdf-schema#label'"/>
                                 <xsl:with-param name="select" select="frbrizer:trim(.)"/>
                              </xsl:call-template>
                           </xsl:copy>
                        </xsl:if>
                        <xsl:if test="@code = 'a'">
                           <xsl:copy>
                              <xsl:call-template name="copy-content">
                                 <xsl:with-param name="type"
                                                  select="'http://rdaregistry.info/Elements/a/datatype/P50385'"/>
                                 <xsl:with-param name="select" select="frbrizer:trim(.)"/>
                              </xsl:call-template>
                           </xsl:copy>
                        </xsl:if>
                        <xsl:if test="@code = 'd'">
                           <xsl:copy>
                              <xsl:call-template name="copy-content">
                                 <xsl:with-param name="type"
                                                  select="'http://rdaregistry.info/Elements/a/datatype/P50339'"/>
                                 <xsl:with-param name="select" select="frbrizer:trim(.)"/>
                              </xsl:call-template>
                           </xsl:copy>
                        </xsl:if>
                        <xsl:if test="@code = '1'">
                           <xsl:copy>
                              <xsl:call-template name="copy-content">
                                 <xsl:with-param name="type"
                                                  select="'http://rdaregistry.info/Elements/x/datatype/P00018'"/>
                                 <xsl:with-param name="select" select="."/>
                              </xsl:call-template>
                           </xsl:copy>
                        </xsl:if>
                     </xsl:for-each>
                  </xsl:copy>
               </xsl:for-each>
               <xsl:for-each select="$record/*:datafield[@tag='111'][. eq $this_field][*:subfield/@code = ('a','d','1')]">
                  <xsl:copy>
                     <xsl:call-template name="copy-attributes"/>
                     <xsl:for-each select="*:subfield[@code = ('a','d','1')]">
                        <xsl:if test="@code = 'a'">
                           <xsl:copy>
                              <xsl:call-template name="copy-content">
                                 <xsl:with-param name="type" select="'http://www.w3.org/2000/01/rdf-schema#label'"/>
                                 <xsl:with-param name="select" select="frbrizer:trim(.)"/>
                              </xsl:call-template>
                           </xsl:copy>
                        </xsl:if>
                        <xsl:if test="@code = 'a'">
                           <xsl:copy>
                              <xsl:call-template name="copy-content">
                                 <xsl:with-param name="type"
                                                  select="'http://rdaregistry.info/Elements/a/datatype/P50385'"/>
                                 <xsl:with-param name="select" select="frbrizer:trim(.)"/>
                              </xsl:call-template>
                           </xsl:copy>
                        </xsl:if>
                        <xsl:if test="@code = 'd'">
                           <xsl:copy>
                              <xsl:call-template name="copy-content">
                                 <xsl:with-param name="type"
                                                  select="'http://rdaregistry.info/Elements/a/datatype/P50339'"/>
                                 <xsl:with-param name="select" select="frbrizer:trim(.)"/>
                              </xsl:call-template>
                           </xsl:copy>
                        </xsl:if>
                        <xsl:if test="@code = '1'">
                           <xsl:copy>
                              <xsl:call-template name="copy-content">
                                 <xsl:with-param name="type"
                                                  select="'http://rdaregistry.info/Elements/x/datatype/P00018'"/>
                                 <xsl:with-param name="select" select="."/>
                              </xsl:call-template>
                           </xsl:copy>
                        </xsl:if>
                     </xsl:for-each>
                  </xsl:copy>
               </xsl:for-each>
               <xsl:for-each select="$record/*:datafield[@tag='700'][. eq $this_field][*:subfield/@code = ('a','d','1')]">
                  <xsl:copy>
                     <xsl:call-template name="copy-attributes"/>
                     <xsl:for-each select="*:subfield[@code = ('a','d','1')]">
                        <xsl:if test="@code = 'a'">
                           <xsl:copy>
                              <xsl:call-template name="copy-content">
                                 <xsl:with-param name="type" select="'http://www.w3.org/2000/01/rdf-schema#label'"/>
                                 <xsl:with-param name="select" select="frbrizer:trim(.)"/>
                              </xsl:call-template>
                           </xsl:copy>
                        </xsl:if>
                        <xsl:if test="@code = 'a'">
                           <xsl:copy>
                              <xsl:call-template name="copy-content">
                                 <xsl:with-param name="type"
                                                  select="'http://rdaregistry.info/Elements/a/datatype/P50385'"/>
                                 <xsl:with-param name="select" select="frbrizer:trim(.)"/>
                              </xsl:call-template>
                           </xsl:copy>
                        </xsl:if>
                        <xsl:if test="@code = 'd'">
                           <xsl:copy>
                              <xsl:call-template name="copy-content">
                                 <xsl:with-param name="type"
                                                  select="'http://rdaregistry.info/Elements/a/datatype/P50339'"/>
                                 <xsl:with-param name="select" select="frbrizer:trim(.)"/>
                              </xsl:call-template>
                           </xsl:copy>
                        </xsl:if>
                        <xsl:if test="@code = '1'">
                           <xsl:copy>
                              <xsl:call-template name="copy-content">
                                 <xsl:with-param name="type"
                                                  select="'http://rdaregistry.info/Elements/x/datatype/P00018'"/>
                                 <xsl:with-param name="select" select="."/>
                              </xsl:call-template>
                           </xsl:copy>
                        </xsl:if>
                     </xsl:for-each>
                  </xsl:copy>
               </xsl:for-each>
               <xsl:for-each select="$record/*:datafield[@tag='710'][. eq $this_field][*:subfield/@code = ('a','d','1')]">
                  <xsl:copy>
                     <xsl:call-template name="copy-attributes"/>
                     <xsl:for-each select="*:subfield[@code = ('a','d','1')]">
                        <xsl:if test="@code = 'a'">
                           <xsl:copy>
                              <xsl:call-template name="copy-content">
                                 <xsl:with-param name="type" select="'http://www.w3.org/2000/01/rdf-schema#label'"/>
                                 <xsl:with-param name="select" select="frbrizer:trim(.)"/>
                              </xsl:call-template>
                           </xsl:copy>
                        </xsl:if>
                        <xsl:if test="@code = 'a'">
                           <xsl:copy>
                              <xsl:call-template name="copy-content">
                                 <xsl:with-param name="type"
                                                  select="'http://rdaregistry.info/Elements/a/datatype/P50385'"/>
                                 <xsl:with-param name="select" select="frbrizer:trim(.)"/>
                              </xsl:call-template>
                           </xsl:copy>
                        </xsl:if>
                        <xsl:if test="@code = 'd'">
                           <xsl:copy>
                              <xsl:call-template name="copy-content">
                                 <xsl:with-param name="type"
                                                  select="'http://rdaregistry.info/Elements/a/datatype/P50339'"/>
                                 <xsl:with-param name="select" select="frbrizer:trim(.)"/>
                              </xsl:call-template>
                           </xsl:copy>
                        </xsl:if>
                        <xsl:if test="@code = '1'">
                           <xsl:copy>
                              <xsl:call-template name="copy-content">
                                 <xsl:with-param name="type"
                                                  select="'http://rdaregistry.info/Elements/x/datatype/P00018'"/>
                                 <xsl:with-param name="select" select="."/>
                              </xsl:call-template>
                           </xsl:copy>
                        </xsl:if>
                     </xsl:for-each>
                  </xsl:copy>
               </xsl:for-each>
               <xsl:for-each select="$record/*:datafield[@tag='711'][. eq $this_field][*:subfield/@code = ('a','d','1')]">
                  <xsl:copy>
                     <xsl:call-template name="copy-attributes"/>
                     <xsl:for-each select="*:subfield[@code = ('a','d','1')]">
                        <xsl:if test="@code = 'a'">
                           <xsl:copy>
                              <xsl:call-template name="copy-content">
                                 <xsl:with-param name="type" select="'http://www.w3.org/2000/01/rdf-schema#label'"/>
                                 <xsl:with-param name="select" select="frbrizer:trim(.)"/>
                              </xsl:call-template>
                           </xsl:copy>
                        </xsl:if>
                        <xsl:if test="@code = 'a'">
                           <xsl:copy>
                              <xsl:call-template name="copy-content">
                                 <xsl:with-param name="type"
                                                  select="'http://rdaregistry.info/Elements/a/datatype/P50385'"/>
                                 <xsl:with-param name="select" select="frbrizer:trim(.)"/>
                              </xsl:call-template>
                           </xsl:copy>
                        </xsl:if>
                        <xsl:if test="@code = 'd'">
                           <xsl:copy>
                              <xsl:call-template name="copy-content">
                                 <xsl:with-param name="type"
                                                  select="'http://rdaregistry.info/Elements/a/datatype/P50339'"/>
                                 <xsl:with-param name="select" select="frbrizer:trim(.)"/>
                              </xsl:call-template>
                           </xsl:copy>
                        </xsl:if>
                        <xsl:if test="@code = '1'">
                           <xsl:copy>
                              <xsl:call-template name="copy-content">
                                 <xsl:with-param name="type"
                                                  select="'http://rdaregistry.info/Elements/x/datatype/P00018'"/>
                                 <xsl:with-param name="select" select="."/>
                              </xsl:call-template>
                           </xsl:copy>
                        </xsl:if>
                     </xsl:for-each>
                  </xsl:copy>
               </xsl:for-each>
            </xsl:element>
         </xsl:for-each>
      </xsl:for-each>
   </xsl:template>
   <xsl:template name="MARC21-130240-Expression">
      <xsl:variable name="this_template_name" select="'MARC21-130240-Expression'"/>
      <xsl:variable name="tag" as="xs:string" select="'130, 240'"/>
      <xsl:variable name="code" as="xs:string" select="'1'"/>
      <xsl:variable name="record" select="."/>
      <xsl:variable name="marcid" select="*:controlfield[@tag='001']"/>
      <xsl:for-each select="node()[@tag=('130','240')][count($record/*:datafield[@tag='700' and @ind2 = '2' and *:subfield/@code = 't']) = 0]">
         <xsl:variable name="this_field"
                        select="(ancestor-or-self::*:datafield, ancestor-or-self::*:controlfield)"/>
         <xsl:variable name="this"
                        select="(ancestor-or-self::*:datafield, ancestor-or-self::*:controlfield)"/>
         <xsl:variable name="anchor_field"
                        select="(ancestor-or-self::*:datafield, ancestor-or-self::*:controlfield)"/>
         <xsl:variable name="anchor"
                        as="xs:string"
                        select="(ancestor-or-self::*:datafield, ancestor-or-self::*:controlfield)"/>
         <xsl:variable name="this_field_position"
                        as="xs:string"
                        select="string(position())"/>
         <xsl:for-each select="node()[@code=('1')][starts-with(., 'http')]">
            <xsl:variable name="this_subfield" select="(ancestor-or-self::*:subfield)"/>
            <xsl:variable name="anchor_subfield" select="(ancestor-or-self::*:subfield)"/>
            <xsl:variable name="this_subfield_code"
                           as="xs:string"
                           select="$this_subfield/@code"/>
            <xsl:variable name="anchor_subfield_code"
                           as="xs:string"
                           select="$this_subfield/@code"/>
            <xsl:variable name="this_subfield_position"
                           as="xs:string"
                           select="string(position())"/>
            <xsl:element name="{name(ancestor-or-self::*:record)}"
                          namespace="{namespace-uri(ancestor-or-self::*:record)}">
               <xsl:attribute name="id"
                               select="string-join(($record/@id,$this_template_name,$tag,$this_subfield_code,$this_field_position,$this_subfield_position), ':')"/>
               <xsl:attribute name="type" select="'http://rdaregistry.info/Elements/c/C10006'"/>
               <xsl:attribute name="templatename" select="$this_template_name"/>
               <xsl:for-each select="$record/*:datafield[@tag='130'][*:subfield/@code = ('a')]">
                  <xsl:copy>
                     <xsl:call-template name="copy-attributes"/>
                     <xsl:for-each select="*:subfield[@code = ('a')]">
                        <xsl:if test="@code = 'a'">
                           <xsl:copy>
                              <xsl:call-template name="copy-content">
                                 <xsl:with-param name="type"
                                                  select="'http://rdaregistry.info/Elements/e/datatype/P20316'"/>
                                 <xsl:with-param name="select" select="frbrizer:trim(.)"/>
                              </xsl:call-template>
                           </xsl:copy>
                        </xsl:if>
                     </xsl:for-each>
                  </xsl:copy>
               </xsl:for-each>
               <xsl:for-each select="$record/*:datafield[@tag='240'][*:subfield/@code = ('a')]">
                  <xsl:copy>
                     <xsl:call-template name="copy-attributes"/>
                     <xsl:for-each select="*:subfield[@code = ('a')]">
                        <xsl:if test="@code = 'a'">
                           <xsl:copy>
                              <xsl:call-template name="copy-content">
                                 <xsl:with-param name="type"
                                                  select="'http://rdaregistry.info/Elements/e/datatype/P20316'"/>
                                 <xsl:with-param name="select" select="frbrizer:trim(.)"/>
                              </xsl:call-template>
                           </xsl:copy>
                        </xsl:if>
                     </xsl:for-each>
                  </xsl:copy>
               </xsl:for-each>
               <xsl:for-each select="$record/*:datafield[@tag='740'][frbrizer:linked($anchor_field, ., true())][*:subfield/@code = ('a')]">
                  <xsl:copy>
                     <xsl:call-template name="copy-attributes"/>
                     <xsl:for-each select="*:subfield[@code = ('a')]">
                        <xsl:if test="@code = 'a'">
                           <xsl:copy>
                              <xsl:call-template name="copy-content">
                                 <xsl:with-param name="type"
                                                  select="'http://rdaregistry.info/Elements/e/datatype/P20315'"/>
                                 <xsl:with-param name="select" select="frbrizer:trim(.)"/>
                              </xsl:call-template>
                           </xsl:copy>
                        </xsl:if>
                     </xsl:for-each>
                  </xsl:copy>
               </xsl:for-each>
               <xsl:for-each select="$record/*:datafield[@tag='245'][*:subfield/@code = ('a')]">
                  <xsl:copy>
                     <xsl:call-template name="copy-attributes"/>
                     <xsl:for-each select="*:subfield[@code = ('a')]">
                        <xsl:if test="@code = 'a'">
                           <xsl:copy>
                              <xsl:call-template name="copy-content">
                                 <xsl:with-param name="type"
                                                  select="'http://rdaregistry.info/Elements/e/datatype/P20312'"/>
                                 <xsl:with-param name="select"
                                                  select="string-join((frbrizer:trim(.), frbrizer:trim(../*:subfield[@code='b'])), ' : ')"/>
                              </xsl:call-template>
                           </xsl:copy>
                        </xsl:if>
                        <xsl:if test="@code = 'a'">
                           <xsl:copy>
                              <xsl:call-template name="copy-content">
                                 <xsl:with-param name="type" select="'http://www.w3.org/2000/01/rdf-schema#label'"/>
                                 <xsl:with-param name="select"
                                                  select="string-join((frbrizer:trim(.), $record/*:datafield[@tag='041']/*:subfield[@code=('a', 'd')][1], $record/*:datafield[@tag='336']/*:subfield[@code='a'][1]), ' / ')"/>
                              </xsl:call-template>
                           </xsl:copy>
                        </xsl:if>
                     </xsl:for-each>
                  </xsl:copy>
               </xsl:for-each>
               <xsl:for-each select="$record/node()[@tag=('130','240')][*:subfield/@code = '1']">
                  <xsl:variable name="target_template_name" select="'MARC21-130240-Work'"/>
                  <xsl:variable name="target_tag_value" select="'130, 240'"/>
                  <xsl:variable name="target_field"
                                 select="(ancestor-or-self::*:datafield, ancestor-or-self::*:controlfield)"/>
                  <xsl:variable name="target_field_position"
                                 as="xs:string"
                                 select="string(position())"/>
                  <xsl:for-each select="node()[@code=('1')][starts-with(., 'http')]">
                     <xsl:variable name="target_subfield" select="."/>
                     <xsl:variable name="target_subfield_code"
                                    as="xs:string"
                                    select="$target_subfield/@code"/>
                     <xsl:variable name="target_subfield_position"
                                    as="xs:string"
                                    select="string(position())"/>
                     <xsl:if test="($target_field = $this_field)">
                        <frbrizer:relationship>
                           <xsl:attribute name="type" select="'http://rdaregistry.info/Elements/e/object/P20231'"/>
                           <xsl:attribute name="href"
                                           select="string-join(($record/@id,$target_template_name,$target_tag_value,$target_subfield_code,$target_field_position,$target_subfield_position), ':')"/>
                           <xsl:if test="$include_internal_key">
                              <xsl:attribute name="intkey"
                                              select="string-join(($record/@id,$target_template_name,$target_tag_value,$target_subfield_code,$target_field_position,$target_subfield_position), ':')"/>
                           </xsl:if>
                        </frbrizer:relationship>
                     </xsl:if>
                  </xsl:for-each>
               </xsl:for-each>
               <xsl:for-each select="$record/node()[@tag=('100','110','111','700','710','711')][exists(*:subfield[@code = '1']/starts-with(., 'http')) and not(*:subfield/@code = 't')]">
                  <xsl:variable name="target_template_name" select="'MARC21-100700Person'"/>
                  <xsl:variable name="target_tag_value" select="'100, 110, 111, 700, 710, 711'"/>
                  <xsl:variable name="target_field"
                                 select="(ancestor-or-self::*:datafield, ancestor-or-self::*:controlfield)"/>
                  <xsl:variable name="target_field_position"
                                 as="xs:string"
                                 select="string(position())"/>
                  <xsl:for-each select="node()[@code=('4')][starts-with(., 'http')]">
                     <xsl:variable name="target_subfield" select="."/>
                     <xsl:variable name="target_subfield_code"
                                    as="xs:string"
                                    select="$target_subfield/@code"/>
                     <xsl:variable name="target_subfield_position"
                                    as="xs:string"
                                    select="string(position())"/>
                     <xsl:if test="(starts-with($target_subfield, 'http://rdaregistry.info/Elements/e/') and frbrizer:linked($anchor_field, $target_field, false()))">
                        <frbrizer:relationship>
                           <xsl:attribute name="type" select="$target_subfield"/>
                           <xsl:attribute name="href"
                                           select="string-join(($record/@id,$target_template_name,$target_tag_value,$target_subfield_code,$target_field_position,$target_subfield_position), ':')"/>
                           <xsl:if test="$include_internal_key">
                              <xsl:attribute name="intkey"
                                              select="string-join(($record/@id,$target_template_name,$target_tag_value,$target_subfield_code,$target_field_position,$target_subfield_position), ':')"/>
                           </xsl:if>
                        </frbrizer:relationship>
                     </xsl:if>
                  </xsl:for-each>
               </xsl:for-each>
               <xsl:for-each select="$record/node()[@tag=('008')][string-length(.) eq 40 and matches(substring(., 36, 3), '[a-z][a-z][a-z]')]">
                  <xsl:variable name="target_template_name" select="'MARC008language'"/>
                  <xsl:variable name="target_tag_value" select="'008'"/>
                  <xsl:variable name="target_field"
                                 select="(ancestor-or-self::*:datafield, ancestor-or-self::*:controlfield)"/>
                  <xsl:variable name="target_field_position"
                                 as="xs:string"
                                 select="string(position())"/>
                  <xsl:if test="(frbrizer:linked($anchor_field, $target_field, false()))">
                     <frbrizer:relationship>
                        <xsl:attribute name="type"
                                        select="'http://rdaregistry.info/Elements/e/datatype/P20006'"/>
                        <xsl:attribute name="href"
                                        select="string-join(($record/@id,$target_template_name,$target_tag_value,$target_field_position), ':')"/>
                        <xsl:if test="$include_internal_key">
                           <xsl:attribute name="intkey"
                                           select="string-join(($record/@id,$target_template_name,$target_tag_value,$target_field_position), ':')"/>
                        </xsl:if>
                     </frbrizer:relationship>
                  </xsl:if>
               </xsl:for-each>
               <xsl:for-each select="$record/node()[@tag=('041')]">
                  <xsl:variable name="target_template_name" select="'MARC041'"/>
                  <xsl:variable name="target_tag_value" select="'041'"/>
                  <xsl:variable name="target_field"
                                 select="(ancestor-or-self::*:datafield, ancestor-or-self::*:controlfield)"/>
                  <xsl:variable name="target_field_position"
                                 as="xs:string"
                                 select="string(position())"/>
                  <xsl:for-each select="node()[@code=('a','d')]">
                     <xsl:variable name="target_subfield" select="."/>
                     <xsl:variable name="target_subfield_code"
                                    as="xs:string"
                                    select="$target_subfield/@code"/>
                     <xsl:variable name="target_subfield_position"
                                    as="xs:string"
                                    select="string(position())"/>
                     <xsl:if test="(frbrizer:linked($anchor_field, $target_field, false()))">
                        <frbrizer:relationship>
                           <xsl:attribute name="type"
                                           select="'http://rdaregistry.info/Elements/e/datatype/P20006'"/>
                           <xsl:attribute name="href"
                                           select="string-join(($record/@id,$target_template_name,$target_tag_value,$target_subfield_code,$target_field_position,$target_subfield_position), ':')"/>
                           <xsl:if test="$include_internal_key">
                              <xsl:attribute name="intkey"
                                              select="string-join(($record/@id,$target_template_name,$target_tag_value,$target_subfield_code,$target_field_position,$target_subfield_position), ':')"/>
                           </xsl:if>
                        </frbrizer:relationship>
                     </xsl:if>
                  </xsl:for-each>
               </xsl:for-each>
               <xsl:for-each select="$record/node()[@tag=('041')]">
                  <xsl:variable name="target_template_name" select="'MARC041additional'"/>
                  <xsl:variable name="target_tag_value" select="'041'"/>
                  <xsl:variable name="target_field"
                                 select="(ancestor-or-self::*:datafield, ancestor-or-self::*:controlfield)"/>
                  <xsl:variable name="target_field_position"
                                 as="xs:string"
                                 select="string(position())"/>
                  <xsl:for-each select="node()[@code=('b','e','f','g','i','j','k','l','m','n','p','q','r','t')]">
                     <xsl:variable name="target_subfield" select="."/>
                     <xsl:variable name="target_subfield_code"
                                    as="xs:string"
                                    select="$target_subfield/@code"/>
                     <xsl:variable name="target_subfield_position"
                                    as="xs:string"
                                    select="string(position())"/>
                     <xsl:if test="(frbrizer:linked($anchor_field, $target_field, false()))">
                        <frbrizer:relationship>
                           <xsl:attribute name="type"
                                           select="'http://rdaregistry.info/Elements/e/datatype/P20065'"/>
                           <xsl:attribute name="href"
                                           select="string-join(($record/@id,$target_template_name,$target_tag_value,$target_subfield_code,$target_field_position,$target_subfield_position), ':')"/>
                           <xsl:if test="$include_internal_key">
                              <xsl:attribute name="intkey"
                                              select="string-join(($record/@id,$target_template_name,$target_tag_value,$target_subfield_code,$target_field_position,$target_subfield_position), ':')"/>
                           </xsl:if>
                        </frbrizer:relationship>
                     </xsl:if>
                  </xsl:for-each>
               </xsl:for-each>
               <xsl:for-each select="$record/node()[@tag=('336')]">
                  <xsl:variable name="target_template_name" select="'MARC336'"/>
                  <xsl:variable name="target_tag_value" select="'336'"/>
                  <xsl:variable name="target_field"
                                 select="(ancestor-or-self::*:datafield, ancestor-or-self::*:controlfield)"/>
                  <xsl:variable name="target_field_position"
                                 as="xs:string"
                                 select="string(position())"/>
                  <xsl:for-each select="node()[@code=('0')][starts-with(., 'http')]">
                     <xsl:variable name="target_subfield" select="."/>
                     <xsl:variable name="target_subfield_code"
                                    as="xs:string"
                                    select="$target_subfield/@code"/>
                     <xsl:variable name="target_subfield_position"
                                    as="xs:string"
                                    select="string(position())"/>
                     <xsl:if test="(frbrizer:linked($anchor_field, $target_field, false()))">
                        <frbrizer:relationship>
                           <xsl:attribute name="type"
                                           select="'http://rdaregistry.info/Elements/e/datatype/P20001'"/>
                           <xsl:attribute name="href"
                                           select="string-join(($record/@id,$target_template_name,$target_tag_value,$target_subfield_code,$target_field_position,$target_subfield_position), ':')"/>
                           <xsl:if test="$include_internal_key">
                              <xsl:attribute name="intkey"
                                              select="string-join(($record/@id,$target_template_name,$target_tag_value,$target_subfield_code,$target_field_position,$target_subfield_position), ':')"/>
                           </xsl:if>
                        </frbrizer:relationship>
                     </xsl:if>
                  </xsl:for-each>
               </xsl:for-each>
            </xsl:element>
         </xsl:for-each>
      </xsl:for-each>
   </xsl:template>
   <xsl:template name="MARC21-130240-Work">
      <xsl:variable name="this_template_name" select="'MARC21-130240-Work'"/>
      <xsl:variable name="tag" as="xs:string" select="'130, 240'"/>
      <xsl:variable name="code" as="xs:string" select="'1'"/>
      <xsl:variable name="record" select="."/>
      <xsl:variable name="marcid" select="*:controlfield[@tag='001']"/>
      <xsl:for-each select="node()[@tag=('130','240')][*:subfield/@code = '1']">
         <xsl:variable name="this_field"
                        select="(ancestor-or-self::*:datafield, ancestor-or-self::*:controlfield)"/>
         <xsl:variable name="this"
                        select="(ancestor-or-self::*:datafield, ancestor-or-self::*:controlfield)"/>
         <xsl:variable name="anchor_field"
                        select="(ancestor-or-self::*:datafield, ancestor-or-self::*:controlfield)"/>
         <xsl:variable name="anchor"
                        as="xs:string"
                        select="(ancestor-or-self::*:datafield, ancestor-or-self::*:controlfield)"/>
         <xsl:variable name="this_field_position"
                        as="xs:string"
                        select="string(position())"/>
         <xsl:for-each select="node()[@code=('1')][starts-with(., 'http')]">
            <xsl:variable name="this_subfield" select="(ancestor-or-self::*:subfield)"/>
            <xsl:variable name="anchor_subfield" select="(ancestor-or-self::*:subfield)"/>
            <xsl:variable name="this_subfield_code"
                           as="xs:string"
                           select="$this_subfield/@code"/>
            <xsl:variable name="anchor_subfield_code"
                           as="xs:string"
                           select="$this_subfield/@code"/>
            <xsl:variable name="this_subfield_position"
                           as="xs:string"
                           select="string(position())"/>
            <xsl:element name="{name(ancestor-or-self::*:record)}"
                          namespace="{namespace-uri(ancestor-or-self::*:record)}">
               <xsl:attribute name="id"
                               select="string-join(($record/@id,$this_template_name,$tag,$this_subfield_code,$this_field_position,$this_subfield_position), ':')"/>
               <xsl:attribute name="type" select="'http://rdaregistry.info/Elements/c/C10001'"/>
               <xsl:attribute name="templatename" select="$this_template_name"/>
               <xsl:for-each select="$record/*:datafield[@tag='130'][. eq $this_field][*:subfield/@code = ('a','f','n','1')]">
                  <xsl:copy>
                     <xsl:call-template name="copy-attributes"/>
                     <xsl:for-each select="*:subfield[@code = ('a','f','n','1')]">
                        <xsl:if test="@code = 'a'">
                           <xsl:copy>
                              <xsl:call-template name="copy-content">
                                 <xsl:with-param name="type" select="'http://www.w3.org/2000/01/rdf-schema#label'"/>
                                 <xsl:with-param name="select" select="frbrizer:trim(.)"/>
                              </xsl:call-template>
                           </xsl:copy>
                        </xsl:if>
                        <xsl:if test="@code = 'a'">
                           <xsl:copy>
                              <xsl:call-template name="copy-content">
                                 <xsl:with-param name="type"
                                                  select="'http://rdaregistry.info/Elements/w/datatype/P10088'"/>
                                 <xsl:with-param name="select"
                                                  select="string-join((frbrizer:trim(.), frbrizer:trim(../*:subfield[@code = 'p'])), ' : ')"/>
                              </xsl:call-template>
                           </xsl:copy>
                        </xsl:if>
                        <xsl:if test="@code = 'f'">
                           <xsl:copy>
                              <xsl:call-template name="copy-content">
                                 <xsl:with-param name="type"
                                                  select="'http://rdaregistry.info/Elements/w/datatype/P10219'"/>
                                 <xsl:with-param name="select" select="."/>
                              </xsl:call-template>
                           </xsl:copy>
                        </xsl:if>
                        <xsl:if test="@code = 'n'">
                           <xsl:copy>
                              <xsl:call-template name="copy-content">
                                 <xsl:with-param name="type"
                                                  select="'http://rdaregistry.info/Elements/w/datatype/P10012'"/>
                                 <xsl:with-param name="select" select="."/>
                              </xsl:call-template>
                           </xsl:copy>
                        </xsl:if>
                        <xsl:if test="@code = '1'">
                           <xsl:copy>
                              <xsl:call-template name="copy-content">
                                 <xsl:with-param name="type"
                                                  select="'http://rdaregistry.info/Elements/x/datatype/P00018'"/>
                                 <xsl:with-param name="select" select="."/>
                              </xsl:call-template>
                           </xsl:copy>
                        </xsl:if>
                     </xsl:for-each>
                  </xsl:copy>
               </xsl:for-each>
               <xsl:for-each select="$record/*:datafield[@tag='240'][. eq $this_field][*:subfield/@code = ('a','f','n','1')]">
                  <xsl:copy>
                     <xsl:call-template name="copy-attributes"/>
                     <xsl:for-each select="*:subfield[@code = ('a','f','n','1')]">
                        <xsl:if test="@code = 'a'">
                           <xsl:copy>
                              <xsl:call-template name="copy-content">
                                 <xsl:with-param name="type" select="'http://www.w3.org/2000/01/rdf-schema#label'"/>
                                 <xsl:with-param name="select"
                                                  select="frbrizer:trim(.) || ' (' || $record/*:datafield[@tag='100']/*:subfield[@code='a']/replace(., '[\s,/:=]+$', '') || ')'"/>
                              </xsl:call-template>
                           </xsl:copy>
                        </xsl:if>
                        <xsl:if test="@code = 'a'">
                           <xsl:copy>
                              <xsl:call-template name="copy-content">
                                 <xsl:with-param name="type"
                                                  select="'http://rdaregistry.info/Elements/w/datatype/P10088'"/>
                                 <xsl:with-param name="select"
                                                  select="string-join((frbrizer:trim(.), frbrizer:trim(../*:subfield[@code = 'p'])), ' : ')"/>
                              </xsl:call-template>
                           </xsl:copy>
                        </xsl:if>
                        <xsl:if test="@code = 'f'">
                           <xsl:copy>
                              <xsl:call-template name="copy-content">
                                 <xsl:with-param name="type"
                                                  select="'http://rdaregistry.info/Elements/w/datatype/P10219'"/>
                                 <xsl:with-param name="select" select="."/>
                              </xsl:call-template>
                           </xsl:copy>
                        </xsl:if>
                        <xsl:if test="@code = 'n'">
                           <xsl:copy>
                              <xsl:call-template name="copy-content">
                                 <xsl:with-param name="type"
                                                  select="'http://rdaregistry.info/Elements/w/datatype/P10012'"/>
                                 <xsl:with-param name="select" select="."/>
                              </xsl:call-template>
                           </xsl:copy>
                        </xsl:if>
                        <xsl:if test="@code = '1'">
                           <xsl:copy>
                              <xsl:call-template name="copy-content">
                                 <xsl:with-param name="type"
                                                  select="'http://rdaregistry.info/Elements/x/datatype/P00018'"/>
                                 <xsl:with-param name="select" select="."/>
                              </xsl:call-template>
                           </xsl:copy>
                        </xsl:if>
                     </xsl:for-each>
                  </xsl:copy>
               </xsl:for-each>
               <xsl:for-each select="$record/*:datafield[@tag='520'][*:subfield/@code = ('a')]">
                  <xsl:copy>
                     <xsl:call-template name="copy-attributes"/>
                     <xsl:for-each select="*:subfield[@code = ('a')]">
                        <xsl:if test="@code = 'a'">
                           <xsl:copy>
                              <xsl:call-template name="copy-content">
                                 <xsl:with-param name="type"
                                                  select="'http://rdaregistry.info/Elements/w/datatype/P10330'"/>
                                 <xsl:with-param name="select" select="."/>
                              </xsl:call-template>
                           </xsl:copy>
                        </xsl:if>
                     </xsl:for-each>
                  </xsl:copy>
               </xsl:for-each>
               <xsl:for-each select="$record/node()[@tag=('100','110','111','700','710','711')][exists(*:subfield[@code = '1']/starts-with(., 'http')) and not(*:subfield/@code = 't')]">
                  <xsl:variable name="target_template_name" select="'MARC21-100700Person'"/>
                  <xsl:variable name="target_tag_value" select="'100, 110, 111, 700, 710, 711'"/>
                  <xsl:variable name="target_field"
                                 select="(ancestor-or-self::*:datafield, ancestor-or-self::*:controlfield)"/>
                  <xsl:variable name="target_field_position"
                                 as="xs:string"
                                 select="string(position())"/>
                  <xsl:for-each select="node()[@code=('4')][starts-with(., 'http')]">
                     <xsl:variable name="target_subfield" select="."/>
                     <xsl:variable name="target_subfield_code"
                                    as="xs:string"
                                    select="$target_subfield/@code"/>
                     <xsl:variable name="target_subfield_position"
                                    as="xs:string"
                                    select="string(position())"/>
                     <xsl:if test="(starts-with($target_subfield, 'http://rdaregistry.info/Elements/w/')  and frbrizer:linked($anchor_field, $target_field, false()))">
                        <frbrizer:relationship>
                           <xsl:attribute name="type" select="$target_subfield"/>
                           <xsl:attribute name="href"
                                           select="string-join(($record/@id,$target_template_name,$target_tag_value,$target_subfield_code,$target_field_position,$target_subfield_position), ':')"/>
                           <xsl:if test="$include_internal_key">
                              <xsl:attribute name="intkey"
                                              select="string-join(($record/@id,$target_template_name,$target_tag_value,$target_subfield_code,$target_field_position,$target_subfield_position), ':')"/>
                           </xsl:if>
                        </frbrizer:relationship>
                     </xsl:if>
                  </xsl:for-each>
               </xsl:for-each>
               <xsl:for-each select="$record/node()[@tag=('600','610','611')][exists(*:subfield[@code = '1']/starts-with(., 'http')) and not(*:subfield/@code = 't')]">
                  <xsl:variable name="target_template_name" select="'MARC21-600-Person'"/>
                  <xsl:variable name="target_tag_value" select="'600, 610, 611'"/>
                  <xsl:variable name="target_field"
                                 select="(ancestor-or-self::*:datafield, ancestor-or-self::*:controlfield)"/>
                  <xsl:variable name="target_field_position"
                                 as="xs:string"
                                 select="string(position())"/>
                  <xsl:if test="(not($target_field/*:subfield/@code = 't') and frbrizer:linked($anchor_field, $target_field, false()))">
                     <frbrizer:relationship>
                        <xsl:attribute name="type" select="'http://rdaregistry.info/Elements/w/object/P10319'"/>
                        <xsl:attribute name="href"
                                        select="string-join(($record/@id,$target_template_name,$target_tag_value,$target_field_position), ':')"/>
                        <xsl:if test="$include_internal_key">
                           <xsl:attribute name="intkey"
                                           select="string-join(($record/@id,$target_template_name,$target_tag_value,$target_field_position), ':')"/>
                        </xsl:if>
                     </frbrizer:relationship>
                  </xsl:if>
               </xsl:for-each>
               <xsl:for-each select="$record/node()[@tag=('600','610','611','630')][*:subfield/@code = '1' and  (if (@tag eq '630') then true() else *:subfield/@code = 't')]">
                  <xsl:variable name="target_template_name" select="'MARC21-6XX-Work'"/>
                  <xsl:variable name="target_tag_value" select="'600, 610, 611, 630'"/>
                  <xsl:variable name="target_field"
                                 select="(ancestor-or-self::*:datafield, ancestor-or-self::*:controlfield)"/>
                  <xsl:variable name="target_field_position"
                                 as="xs:string"
                                 select="string(position())"/>
                  <xsl:for-each select="node()[@code=('1')][starts-with(., 'http')]">
                     <xsl:variable name="target_subfield" select="."/>
                     <xsl:variable name="target_subfield_code"
                                    as="xs:string"
                                    select="$target_subfield/@code"/>
                     <xsl:variable name="target_subfield_position"
                                    as="xs:string"
                                    select="string(position())"/>
                     <xsl:if test="(not($this_field/*:subfield/@code = '1') or not($this_field/*:subfield[@code = '1'] = $target_field/*:subfield[@code = '1'])  and frbrizer:linked($anchor_field, $target_field, false()))">
                        <frbrizer:relationship>
                           <xsl:attribute name="type" select="'http://rdaregistry.info/Elements/w/object/P10257'"/>
                           <xsl:attribute name="href"
                                           select="string-join(($record/@id,$target_template_name,$target_tag_value,$target_subfield_code,$target_field_position,$target_subfield_position), ':')"/>
                           <xsl:if test="$include_internal_key">
                              <xsl:attribute name="intkey"
                                              select="string-join(($record/@id,$target_template_name,$target_tag_value,$target_subfield_code,$target_field_position,$target_subfield_position), ':')"/>
                           </xsl:if>
                        </frbrizer:relationship>
                     </xsl:if>
                  </xsl:for-each>
               </xsl:for-each>
               <xsl:for-each select="$record/node()[@tag=('700','710','711','730')][exists(*:subfield[@code = '1' and starts-with(., 'http')]) and not(@ind2 = '2') and (if (@tag eq '730') then true() else *:subfield/@code = 't')]">
                  <xsl:variable name="target_template_name" select="'MARC21-700-Related-Work'"/>
                  <xsl:variable name="target_tag_value" select="'700, 710, 711, 730'"/>
                  <xsl:variable name="target_field"
                                 select="(ancestor-or-self::*:datafield, ancestor-or-self::*:controlfield)"/>
                  <xsl:variable name="target_field_position"
                                 as="xs:string"
                                 select="string(position())"/>
                  <xsl:for-each select="node()[@code=('4')][starts-with(., 'http')]">
                     <xsl:variable name="target_subfield" select="."/>
                     <xsl:variable name="target_subfield_code"
                                    as="xs:string"
                                    select="$target_subfield/@code"/>
                     <xsl:variable name="target_subfield_position"
                                    as="xs:string"
                                    select="string(position())"/>
                     <xsl:if test="(starts-with($target_subfield, 'http://rdaregistry.info/Elements/w/') and frbrizer:linked($anchor_field, $target_field, false()))">
                        <frbrizer:relationship>
                           <xsl:attribute name="type" select="$target_subfield"/>
                           <xsl:attribute name="href"
                                           select="string-join(($record/@id,$target_template_name,$target_tag_value,$target_subfield_code,$target_field_position,$target_subfield_position), ':')"/>
                           <xsl:if test="$include_internal_key">
                              <xsl:attribute name="intkey"
                                              select="string-join(($record/@id,$target_template_name,$target_tag_value,$target_subfield_code,$target_field_position,$target_subfield_position), ':')"/>
                           </xsl:if>
                        </frbrizer:relationship>
                     </xsl:if>
                  </xsl:for-each>
               </xsl:for-each>
               <xsl:for-each select="$record/node()[@tag=('758')]">
                  <xsl:variable name="target_template_name" select="'MARC21-758-Related-Work'"/>
                  <xsl:variable name="target_tag_value" select="'758'"/>
                  <xsl:variable name="target_field"
                                 select="(ancestor-or-self::*:datafield, ancestor-or-self::*:controlfield)"/>
                  <xsl:variable name="target_field_position"
                                 as="xs:string"
                                 select="string(position())"/>
                  <xsl:for-each select="node()[@code=('4')][starts-with(., 'http') and exists($this_field/*:subfield[@code = '1']/starts-with(., 'http')) ]">
                     <xsl:variable name="target_subfield" select="."/>
                     <xsl:variable name="target_subfield_code"
                                    as="xs:string"
                                    select="$target_subfield/@code"/>
                     <xsl:variable name="target_subfield_position"
                                    as="xs:string"
                                    select="string(position())"/>
                     <xsl:if test="(starts-with($target_subfield, 'http://rdaregistry.info/Elements/w/') and frbrizer:linked($anchor_field, $target_field, false()))">
                        <frbrizer:relationship>
                           <xsl:attribute name="type" select="$target_subfield"/>
                           <xsl:attribute name="href"
                                           select="string-join(($record/@id,$target_template_name,$target_tag_value,$target_subfield_code,$target_field_position,$target_subfield_position), ':')"/>
                           <xsl:if test="$include_internal_key">
                              <xsl:attribute name="intkey"
                                              select="string-join(($record/@id,$target_template_name,$target_tag_value,$target_subfield_code,$target_field_position,$target_subfield_position), ':')"/>
                           </xsl:if>
                        </frbrizer:relationship>
                     </xsl:if>
                  </xsl:for-each>
               </xsl:for-each>
               <xsl:for-each select="$record/node()[@tag=('800','810','811','830')]">
                  <xsl:variable name="target_template_name" select="'MARC21-8XX-Work-Series'"/>
                  <xsl:variable name="target_tag_value" select="'800, 810, 811, 830'"/>
                  <xsl:variable name="target_field"
                                 select="(ancestor-or-self::*:datafield, ancestor-or-self::*:controlfield)"/>
                  <xsl:variable name="target_field_position"
                                 as="xs:string"
                                 select="string(position())"/>
                  <xsl:for-each select="node()[@code=('1')][starts-with(., 'http')]">
                     <xsl:variable name="target_subfield" select="."/>
                     <xsl:variable name="target_subfield_code"
                                    as="xs:string"
                                    select="$target_subfield/@code"/>
                     <xsl:variable name="target_subfield_position"
                                    as="xs:string"
                                    select="string(position())"/>
                     <frbrizer:relationship>
                        <xsl:attribute name="type" select="'http://rdaregistry.info/Elements/w/object/P10019'"/>
                        <xsl:attribute name="href"
                                        select="string-join(($record/@id,$target_template_name,$target_tag_value,$target_subfield_code,$target_field_position,$target_subfield_position), ':')"/>
                        <xsl:if test="$include_internal_key">
                           <xsl:attribute name="intkey"
                                           select="string-join(($record/@id,$target_template_name,$target_tag_value,$target_subfield_code,$target_field_position,$target_subfield_position), ':')"/>
                        </xsl:if>
                     </frbrizer:relationship>
                  </xsl:for-each>
               </xsl:for-each>
               <xsl:for-each select="$record/node()[@tag=('380')]">
                  <xsl:variable name="target_template_name" select="'MARC380'"/>
                  <xsl:variable name="target_tag_value" select="'380'"/>
                  <xsl:variable name="target_field"
                                 select="(ancestor-or-self::*:datafield, ancestor-or-self::*:controlfield)"/>
                  <xsl:variable name="target_field_position"
                                 as="xs:string"
                                 select="string(position())"/>
                  <xsl:for-each select="node()[@code=('0')][starts-with(., 'http')]">
                     <xsl:variable name="target_subfield" select="."/>
                     <xsl:variable name="target_subfield_code"
                                    as="xs:string"
                                    select="$target_subfield/@code"/>
                     <xsl:variable name="target_subfield_position"
                                    as="xs:string"
                                    select="string(position())"/>
                     <xsl:if test="(frbrizer:linked($anchor_field, $target_field, false()))">
                        <frbrizer:relationship>
                           <xsl:attribute name="type"
                                           select="'http://rdaregistry.info/Elements/w/datatype/P10004'"/>
                           <xsl:attribute name="href"
                                           select="string-join(($record/@id,$target_template_name,$target_tag_value,$target_subfield_code,$target_field_position,$target_subfield_position), ':')"/>
                           <xsl:if test="$include_internal_key">
                              <xsl:attribute name="intkey"
                                              select="string-join(($record/@id,$target_template_name,$target_tag_value,$target_subfield_code,$target_field_position,$target_subfield_position), ':')"/>
                           </xsl:if>
                        </frbrizer:relationship>
                     </xsl:if>
                  </xsl:for-each>
               </xsl:for-each>
            </xsl:element>
         </xsl:for-each>
      </xsl:for-each>
   </xsl:template>
   <xsl:template name="MARC21-245-Manifestation">
      <xsl:variable name="this_template_name" select="'MARC21-245-Manifestation'"/>
      <xsl:variable name="tag" as="xs:string" select="'245'"/>
      <xsl:variable name="record" select="."/>
      <xsl:variable name="marcid" select="*:controlfield[@tag='001']"/>
      <xsl:for-each select="node()[@tag=('245')]">
         <xsl:variable name="this_field"
                        select="(ancestor-or-self::*:datafield, ancestor-or-self::*:controlfield)"/>
         <xsl:variable name="this"
                        select="(ancestor-or-self::*:datafield, ancestor-or-self::*:controlfield)"/>
         <xsl:variable name="anchor_field"
                        select="(ancestor-or-self::*:datafield, ancestor-or-self::*:controlfield)"/>
         <xsl:variable name="anchor"
                        as="xs:string"
                        select="(ancestor-or-self::*:datafield, ancestor-or-self::*:controlfield)"/>
         <xsl:variable name="this_field_position"
                        as="xs:string"
                        select="string(position())"/>
         <xsl:element name="{name(ancestor-or-self::*:record)}"
                       namespace="{namespace-uri(ancestor-or-self::*:record)}">
            <xsl:attribute name="id"
                            select="string-join(($record/@id,$this_template_name,$tag,$this_field_position), ':')"/>
            <xsl:attribute name="type" select="'http://rdaregistry.info/Elements/c/C10007'"/>
            <xsl:attribute name="templatename" select="$this_template_name"/>
            <xsl:for-each select="$record/*:controlfield[@tag='001']">
               <xsl:copy>
                  <xsl:call-template name="copy-content">
                     <xsl:with-param name="type" select="'marc'"/>
                     <xsl:with-param name="select" select="."/>
                     <xsl:with-param name="marcid" select="$marcid"/>
                  </xsl:call-template>
               </xsl:copy>
            </xsl:for-each>
            <xsl:for-each select="$record/*:controlfield[@tag='003']">
               <xsl:copy>
                  <xsl:call-template name="copy-content">
                     <xsl:with-param name="type" select="'marc'"/>
                     <xsl:with-param name="select" select="."/>
                     <xsl:with-param name="marcid" select="$marcid"/>
                  </xsl:call-template>
               </xsl:copy>
            </xsl:for-each>
            <xsl:for-each select="$record/*:controlfield[@tag='008']">
               <xsl:copy>
                  <xsl:call-template name="copy-content">
                     <xsl:with-param name="type" select="'marc'"/>
                     <xsl:with-param name="select" select="."/>
                     <xsl:with-param name="marcid" select="$marcid"/>
                  </xsl:call-template>
               </xsl:copy>
            </xsl:for-each>
            <xsl:for-each select="$record/*:datafield[@tag='020'][*:subfield/@code = ('a')]">
               <xsl:copy>
                  <xsl:call-template name="copy-attributes"/>
                  <xsl:for-each select="*:subfield[@code = ('a')]">
                     <xsl:if test="@code = 'a'">
                        <xsl:copy>
                           <xsl:call-template name="copy-content">
                              <xsl:with-param name="type" select="'http://www.w3.org/2000/01/rdf-schema#label'"/>
                              <xsl:with-param name="select" select="'ISBN' || frbrizer:trim(.)"/>
                           </xsl:call-template>
                        </xsl:copy>
                     </xsl:if>
                     <xsl:if test="@code = 'a'">
                        <xsl:copy>
                           <xsl:call-template name="copy-content">
                              <xsl:with-param name="type"
                                               select="'http://rdaregistry.info/Elements/m/datatype/P30004'"/>
                              <xsl:with-param name="select" select="'ISBN ' || ."/>
                           </xsl:call-template>
                        </xsl:copy>
                     </xsl:if>
                     <xsl:if test="@code = 'a'">
                        <xsl:copy>
                           <xsl:call-template name="copy-content">
                              <xsl:with-param name="type"
                                               select="'http://rdaregistry.info/Elements/x/datatype/P00018'"/>
                              <xsl:with-param name="select"
                                               select="'isbn-' || replace(., '\D', '') || (if (../*:subfield[@code='q' and matches(., '^[0-9]*$')]) then '-' || ../*:subfield[@code='q' and matches(., '^[0-9]*$')][1]  else '')"/>
                           </xsl:call-template>
                        </xsl:copy>
                     </xsl:if>
                  </xsl:for-each>
               </xsl:copy>
            </xsl:for-each>
            <xsl:for-each select="$record/*:datafield[@tag='022'][*:subfield/@code = ('a')]">
               <xsl:copy>
                  <xsl:call-template name="copy-attributes"/>
                  <xsl:for-each select="*:subfield[@code = ('a')]">
                     <xsl:if test="@code = 'a'">
                        <xsl:copy>
                           <xsl:call-template name="copy-content">
                              <xsl:with-param name="type"
                                               select="'http://rdaregistry.info/Elements/m/datatype/P30004'"/>
                              <xsl:with-param name="select" select="'ISSN ' || ."/>
                           </xsl:call-template>
                        </xsl:copy>
                     </xsl:if>
                     <xsl:if test="@code = 'a'">
                        <xsl:copy>
                           <xsl:call-template name="copy-content">
                              <xsl:with-param name="type"
                                               select="'http://rdaregistry.info/Elements/x/datatype/P00018'"/>
                              <xsl:with-param name="select" select="concat('issn-', ./replace(., '\D', ''))"/>
                           </xsl:call-template>
                        </xsl:copy>
                     </xsl:if>
                  </xsl:for-each>
               </xsl:copy>
            </xsl:for-each>
            <xsl:for-each select="$record/*:datafield[@tag='024'][*:subfield/@code = ('a')]">
               <xsl:copy>
                  <xsl:call-template name="copy-attributes"/>
                  <xsl:for-each select="*:subfield[@code = ('a')]">
                     <xsl:if test="@code = 'a'">
                        <xsl:copy>
                           <xsl:call-template name="copy-content">
                              <xsl:with-param name="type"
                                               select="'http://rdaregistry.info/Elements/m/datatype/P30004'"/>
                              <xsl:with-param name="select" select="frbrizer:idprefix(../@ind1) || ' ' || ."/>
                           </xsl:call-template>
                        </xsl:copy>
                     </xsl:if>
                     <xsl:if test="@code = 'a'">
                        <xsl:copy>
                           <xsl:call-template name="copy-content">
                              <xsl:with-param name="type"
                                               select="'http://rdaregistry.info/Elements/x/datatype/P00018'"/>
                              <xsl:with-param name="select"
                                               select="concat(frbrizer:idprefix(../@ind1) ,'-', replace(., '\D', ''))"/>
                           </xsl:call-template>
                        </xsl:copy>
                     </xsl:if>
                  </xsl:for-each>
               </xsl:copy>
            </xsl:for-each>
            <xsl:for-each select="$record/*:datafield[@tag='245'][. = $this_field][*:subfield/@code = ('a','b','c','n','p')]">
               <xsl:copy>
                  <xsl:call-template name="copy-attributes"/>
                  <xsl:for-each select="*:subfield[@code = ('a','b','c','n','p')]">
                     <xsl:if test="@code = 'a'">
                        <xsl:copy>
                           <xsl:call-template name="copy-content">
                              <xsl:with-param name="type"
                                               select="'http://rdaregistry.info/Elements/m/datatype/P30156'"/>
                              <xsl:with-param name="select" select="frbrizer:trim(.)"/>
                           </xsl:call-template>
                        </xsl:copy>
                     </xsl:if>
                     <xsl:if test="@code = 'b'">
                        <xsl:copy>
                           <xsl:call-template name="copy-content">
                              <xsl:with-param name="type"
                                               select="'http://rdaregistry.info/Elements/m/datatype/P30142'"/>
                              <xsl:with-param name="select" select="frbrizer:trim(.)"/>
                           </xsl:call-template>
                        </xsl:copy>
                     </xsl:if>
                     <xsl:if test="@code = 'c'">
                        <xsl:copy>
                           <xsl:call-template name="copy-content">
                              <xsl:with-param name="type"
                                               select="'http://rdaregistry.info/Elements/m/datatype/P30117'"/>
                              <xsl:with-param name="select" select="frbrizer:trim(.)"/>
                           </xsl:call-template>
                        </xsl:copy>
                     </xsl:if>
                     <xsl:if test="@code = 'n'">
                        <xsl:copy>
                           <xsl:call-template name="copy-content">
                              <xsl:with-param name="type"
                                               select="'http://rdaregistry.info/Elements/m/datatype/P30014'"/>
                              <xsl:with-param name="select" select="frbrizer:trim(.)"/>
                           </xsl:call-template>
                        </xsl:copy>
                     </xsl:if>
                     <xsl:if test="@code = 'p'">
                        <xsl:copy>
                           <xsl:call-template name="copy-content">
                              <xsl:with-param name="type"
                                               select="'http://rdaregistry.info/Elements/m/datatype/P30134'"/>
                              <xsl:with-param name="select" select="frbrizer:trim(.)"/>
                           </xsl:call-template>
                        </xsl:copy>
                     </xsl:if>
                  </xsl:for-each>
               </xsl:copy>
            </xsl:for-each>
            <xsl:for-each select="$record/*:datafield[@tag='250'][*:subfield/@code = ('a')]">
               <xsl:copy>
                  <xsl:call-template name="copy-attributes"/>
                  <xsl:for-each select="*:subfield[@code = ('a')]">
                     <xsl:if test="@code = 'a'">
                        <xsl:copy>
                           <xsl:call-template name="copy-content">
                              <xsl:with-param name="type"
                                               select="'http://rdaregistry.info/Elements/m/datatype/P30107'"/>
                              <xsl:with-param name="select" select="."/>
                           </xsl:call-template>
                        </xsl:copy>
                     </xsl:if>
                  </xsl:for-each>
               </xsl:copy>
            </xsl:for-each>
            <xsl:for-each select="$record/*:datafield[@tag='260'][*:subfield/@code = ('x','a','b','c','e','f','g')]">
               <xsl:copy>
                  <xsl:call-template name="copy-attributes"/>
                  <xsl:for-each select="*:subfield[@code = ('x','a','b','c','e','f','g')]">
                     <xsl:if test="@code = 'x'">
                        <xsl:copy>
                           <xsl:call-template name="copy-content">
                              <xsl:with-param name="type"
                                               select="'http://rdaregistry.info/Elements/m/datatype/P30111'"/>
                              <xsl:with-param name="select" select="frbrizer:publication(..)"/>
                           </xsl:call-template>
                        </xsl:copy>
                     </xsl:if>
                     <xsl:if test="@code = 'a'">
                        <xsl:copy>
                           <xsl:call-template name="copy-content">
                              <xsl:with-param name="type"
                                               select="'http://rdaregistry.info/Elements/m/datatype/P30111'"/>
                              <xsl:with-param name="select" select="frbrizer:publication(..)"/>
                           </xsl:call-template>
                        </xsl:copy>
                     </xsl:if>
                     <xsl:if test="@code = 'b'">
                        <xsl:copy>
                           <xsl:call-template name="copy-content">
                              <xsl:with-param name="type"
                                               select="'http://rdaregistry.info/Elements/m/datatype/P30111'"/>
                              <xsl:with-param name="select" select="frbrizer:publication(..)"/>
                           </xsl:call-template>
                        </xsl:copy>
                     </xsl:if>
                     <xsl:if test="@code = 'c'">
                        <xsl:copy>
                           <xsl:call-template name="copy-content">
                              <xsl:with-param name="type"
                                               select="'http://rdaregistry.info/Elements/m/datatype/P30111'"/>
                              <xsl:with-param name="select" select="frbrizer:publication(..)"/>
                           </xsl:call-template>
                        </xsl:copy>
                     </xsl:if>
                     <xsl:if test="@code = 'a'">
                        <xsl:copy>
                           <xsl:call-template name="copy-content">
                              <xsl:with-param name="type"
                                               select="'http://rdaregistry.info/Elements/m/datatype/P30088'"/>
                              <xsl:with-param name="select" select="frbrizer:trim(.)"/>
                           </xsl:call-template>
                        </xsl:copy>
                     </xsl:if>
                     <xsl:if test="@code = 'b'">
                        <xsl:copy>
                           <xsl:call-template name="copy-content">
                              <xsl:with-param name="type"
                                               select="'http://rdaregistry.info/Elements/m/datatype/P30083'"/>
                              <xsl:with-param name="select" select="frbrizer:trim(.)"/>
                           </xsl:call-template>
                        </xsl:copy>
                     </xsl:if>
                     <xsl:if test="@code = 'c'">
                        <xsl:copy>
                           <xsl:call-template name="copy-content">
                              <xsl:with-param name="type"
                                               select="'http://rdaregistry.info/Elements/m/datatype/P30011'"/>
                              <xsl:with-param name="select" select="frbrizer:trim(.)"/>
                           </xsl:call-template>
                        </xsl:copy>
                     </xsl:if>
                     <xsl:if test="@code = 'e'">
                        <xsl:copy>
                           <xsl:call-template name="copy-content">
                              <xsl:with-param name="type"
                                               select="'http://rdaregistry.info/Elements/m/datatype/P30087'"/>
                              <xsl:with-param name="select" select="frbrizer:trim(.)"/>
                           </xsl:call-template>
                        </xsl:copy>
                     </xsl:if>
                     <xsl:if test="@code = 'f'">
                        <xsl:copy>
                           <xsl:call-template name="copy-content">
                              <xsl:with-param name="type"
                                               select="'http://rdaregistry.info/Elements/m/datatype/P30175'"/>
                              <xsl:with-param name="select" select="frbrizer:trim(.)"/>
                           </xsl:call-template>
                        </xsl:copy>
                     </xsl:if>
                     <xsl:if test="@code = 'g'">
                        <xsl:copy>
                           <xsl:call-template name="copy-content">
                              <xsl:with-param name="type"
                                               select="'http://rdaregistry.info/Elements/m/datatype/P30010'"/>
                              <xsl:with-param name="select" select="frbrizer:trim(.)"/>
                           </xsl:call-template>
                        </xsl:copy>
                     </xsl:if>
                  </xsl:for-each>
               </xsl:copy>
            </xsl:for-each>
            <xsl:for-each select="$record/*:datafield[@tag='264'][@ind2='0'][*:subfield/@code = ('a','b','c')]">
               <xsl:copy>
                  <xsl:call-template name="copy-attributes"/>
                  <xsl:for-each select="*:subfield[@code = ('a','b','c')]">
                     <xsl:if test="@code = 'a'">
                        <xsl:copy>
                           <xsl:call-template name="copy-content">
                              <xsl:with-param name="type"
                                               select="'http://rdaregistry.info/Elements/m/datatype/P30110'"/>
                              <xsl:with-param name="select" select="frbrizer:publication(..)"/>
                           </xsl:call-template>
                        </xsl:copy>
                     </xsl:if>
                     <xsl:if test="@code = 'a'">
                        <xsl:copy>
                           <xsl:call-template name="copy-content">
                              <xsl:with-param name="type"
                                               select="'http://rdaregistry.info/Elements/m/datatype/P30086'"/>
                              <xsl:with-param name="select" select="frbrizer:trim(.)"/>
                           </xsl:call-template>
                        </xsl:copy>
                     </xsl:if>
                     <xsl:if test="@code = 'b'">
                        <xsl:copy>
                           <xsl:call-template name="copy-content">
                              <xsl:with-param name="type"
                                               select="'http://rdaregistry.info/Elements/m/datatype/P30174'"/>
                              <xsl:with-param name="select" select="frbrizer:trim(.)"/>
                           </xsl:call-template>
                        </xsl:copy>
                     </xsl:if>
                     <xsl:if test="@code = 'c'">
                        <xsl:copy>
                           <xsl:call-template name="copy-content">
                              <xsl:with-param name="type"
                                               select="'http://rdaregistry.info/Elements/m/datatype/P30009'"/>
                              <xsl:with-param name="select" select="frbrizer:trim(.)"/>
                           </xsl:call-template>
                        </xsl:copy>
                     </xsl:if>
                  </xsl:for-each>
               </xsl:copy>
            </xsl:for-each>
            <xsl:for-each select="$record/*:datafield[@tag='264'][@ind2='1'][*:subfield/@code = ('a','b','c')]">
               <xsl:copy>
                  <xsl:call-template name="copy-attributes"/>
                  <xsl:for-each select="*:subfield[@code = ('a','b','c')]">
                     <xsl:if test="@code = 'a'">
                        <xsl:copy>
                           <xsl:call-template name="copy-content">
                              <xsl:with-param name="type"
                                               select="'http://rdaregistry.info/Elements/m/datatype/P30111'"/>
                              <xsl:with-param name="select" select="frbrizer:publication(..)"/>
                           </xsl:call-template>
                        </xsl:copy>
                     </xsl:if>
                     <xsl:if test="@code = 'a'">
                        <xsl:copy>
                           <xsl:call-template name="copy-content">
                              <xsl:with-param name="type"
                                               select="'http://rdaregistry.info/Elements/m/datatype/P30088'"/>
                              <xsl:with-param name="select" select="frbrizer:trim(.)"/>
                           </xsl:call-template>
                        </xsl:copy>
                     </xsl:if>
                     <xsl:if test="@code = 'b'">
                        <xsl:copy>
                           <xsl:call-template name="copy-content">
                              <xsl:with-param name="type"
                                               select="'http://rdaregistry.info/Elements/m/datatype/P30083'"/>
                              <xsl:with-param name="select" select="frbrizer:trim(.)"/>
                           </xsl:call-template>
                        </xsl:copy>
                     </xsl:if>
                     <xsl:if test="@code = 'c'">
                        <xsl:copy>
                           <xsl:call-template name="copy-content">
                              <xsl:with-param name="type"
                                               select="'http://rdaregistry.info/Elements/m/datatype/P30011'"/>
                              <xsl:with-param name="select" select="frbrizer:trim(.)"/>
                           </xsl:call-template>
                        </xsl:copy>
                     </xsl:if>
                  </xsl:for-each>
               </xsl:copy>
            </xsl:for-each>
            <xsl:for-each select="$record/*:datafield[@tag='264'][@ind2='2'][*:subfield/@code = ('a','b','c')]">
               <xsl:copy>
                  <xsl:call-template name="copy-attributes"/>
                  <xsl:for-each select="*:subfield[@code = ('a','b','c')]">
                     <xsl:if test="@code = 'a'">
                        <xsl:copy>
                           <xsl:call-template name="copy-content">
                              <xsl:with-param name="type"
                                               select="'http://rdaregistry.info/Elements/m/datatype/P30108'"/>
                              <xsl:with-param name="select" select="frbrizer:publication(..)"/>
                           </xsl:call-template>
                        </xsl:copy>
                     </xsl:if>
                     <xsl:if test="@code = 'a'">
                        <xsl:copy>
                           <xsl:call-template name="copy-content">
                              <xsl:with-param name="type"
                                               select="'http://rdaregistry.info/Elements/m/datatype/P30085'"/>
                              <xsl:with-param name="select" select="frbrizer:trim(.)"/>
                           </xsl:call-template>
                        </xsl:copy>
                     </xsl:if>
                     <xsl:if test="@code = 'b'">
                        <xsl:copy>
                           <xsl:call-template name="copy-content">
                              <xsl:with-param name="type"
                                               select="'http://rdaregistry.info/Elements/m/datatype/P30173'"/>
                              <xsl:with-param name="select" select="frbrizer:trim(.)"/>
                           </xsl:call-template>
                        </xsl:copy>
                     </xsl:if>
                     <xsl:if test="@code = 'c'">
                        <xsl:copy>
                           <xsl:call-template name="copy-content">
                              <xsl:with-param name="type"
                                               select="'http://rdaregistry.info/Elements/m/datatype/P30008'"/>
                              <xsl:with-param name="select" select="frbrizer:trim(.)"/>
                           </xsl:call-template>
                        </xsl:copy>
                     </xsl:if>
                  </xsl:for-each>
               </xsl:copy>
            </xsl:for-each>
            <xsl:for-each select="$record/*:datafield[@tag='264'][@ind2='3'][*:subfield/@code = ('a','b','c')]">
               <xsl:copy>
                  <xsl:call-template name="copy-attributes"/>
                  <xsl:for-each select="*:subfield[@code = ('a','b','c')]">
                     <xsl:if test="@code = 'a'">
                        <xsl:copy>
                           <xsl:call-template name="copy-content">
                              <xsl:with-param name="type"
                                               select="'http://rdaregistry.info/Elements/m/datatype/P30109'"/>
                              <xsl:with-param name="select" select="frbrizer:publication(..)"/>
                           </xsl:call-template>
                        </xsl:copy>
                     </xsl:if>
                     <xsl:if test="@code = 'a'">
                        <xsl:copy>
                           <xsl:call-template name="copy-content">
                              <xsl:with-param name="type"
                                               select="'http://rdaregistry.info/Elements/m/datatype/P30087'"/>
                              <xsl:with-param name="select" select="frbrizer:trim(.)"/>
                           </xsl:call-template>
                        </xsl:copy>
                     </xsl:if>
                     <xsl:if test="@code = 'b'">
                        <xsl:copy>
                           <xsl:call-template name="copy-content">
                              <xsl:with-param name="type"
                                               select="'http://rdaregistry.info/Elements/m/datatype/P30175'"/>
                              <xsl:with-param name="select" select="frbrizer:trim(.)"/>
                           </xsl:call-template>
                        </xsl:copy>
                     </xsl:if>
                     <xsl:if test="@code = 'c'">
                        <xsl:copy>
                           <xsl:call-template name="copy-content">
                              <xsl:with-param name="type"
                                               select="'http://rdaregistry.info/Elements/m/datatype/P30010'"/>
                              <xsl:with-param name="select" select="frbrizer:trim(.)"/>
                           </xsl:call-template>
                        </xsl:copy>
                     </xsl:if>
                  </xsl:for-each>
               </xsl:copy>
            </xsl:for-each>
            <xsl:for-each select="$record/*:datafield[@tag='264'][@ind2='4'][*:subfield/@code = ('c')]">
               <xsl:copy>
                  <xsl:call-template name="copy-attributes"/>
                  <xsl:for-each select="*:subfield[@code = ('c')]">
                     <xsl:if test="@code = 'c'">
                        <xsl:copy>
                           <xsl:call-template name="copy-content">
                              <xsl:with-param name="type"
                                               select="'http://rdaregistry.info/Elements/m/datatype/P30007'"/>
                              <xsl:with-param name="select" select="frbrizer:trim(.)"/>
                           </xsl:call-template>
                        </xsl:copy>
                     </xsl:if>
                  </xsl:for-each>
               </xsl:copy>
            </xsl:for-each>
            <xsl:for-each select="$record/*:datafield[@tag='300'][*:subfield/@code = ('a')]">
               <xsl:copy>
                  <xsl:call-template name="copy-attributes"/>
                  <xsl:for-each select="*:subfield[@code = ('a')]">
                     <xsl:if test="@code = 'a'">
                        <xsl:copy>
                           <xsl:call-template name="copy-content">
                              <xsl:with-param name="type"
                                               select="'http://rdaregistry.info/Elements/m/datatype/P30182'"/>
                              <xsl:with-param name="select" select="frbrizer:extent(..)"/>
                           </xsl:call-template>
                        </xsl:copy>
                     </xsl:if>
                  </xsl:for-each>
               </xsl:copy>
            </xsl:for-each>
            <xsl:for-each select="$record/*:datafield[@tag='337'][*:subfield/@code = ('0')]">
               <xsl:copy>
                  <xsl:call-template name="copy-attributes"/>
                  <xsl:for-each select="*:subfield[@code = ('0')]">
                     <xsl:if test="@code = '0'">
                        <xsl:copy>
                           <xsl:call-template name="copy-content">
                              <xsl:with-param name="type"
                                               select="'http://rdaregistry.info/Elements/m/datatype/P30002'"/>
                              <xsl:with-param name="select" select="."/>
                           </xsl:call-template>
                        </xsl:copy>
                     </xsl:if>
                  </xsl:for-each>
               </xsl:copy>
            </xsl:for-each>
            <xsl:for-each select="$record/*:datafield[@tag='338'][*:subfield/@code = ('0')]">
               <xsl:copy>
                  <xsl:call-template name="copy-attributes"/>
                  <xsl:for-each select="*:subfield[@code = ('0')]">
                     <xsl:if test="@code = '0'">
                        <xsl:copy>
                           <xsl:call-template name="copy-content">
                              <xsl:with-param name="type"
                                               select="'http://rdaregistry.info/Elements/m/datatype/P30001'"/>
                              <xsl:with-param name="select" select="."/>
                           </xsl:call-template>
                        </xsl:copy>
                     </xsl:if>
                  </xsl:for-each>
               </xsl:copy>
            </xsl:for-each>
            <xsl:for-each select="$record/*:datafield[@tag='490'][*:subfield/@code = ('a','v')]">
               <xsl:copy>
                  <xsl:call-template name="copy-attributes"/>
                  <xsl:for-each select="*:subfield[@code = ('a','v')]">
                     <xsl:if test="@code = 'a'">
                        <xsl:copy>
                           <xsl:call-template name="copy-content">
                              <xsl:with-param name="type"
                                               select="'http://rdaregistry.info/Elements/m/datatype/P30106'"/>
                              <xsl:with-param name="select" select="frbrizer:trim(.)"/>
                           </xsl:call-template>
                        </xsl:copy>
                     </xsl:if>
                     <xsl:if test="@code = 'v'">
                        <xsl:copy>
                           <xsl:call-template name="copy-content">
                              <xsl:with-param name="type"
                                               select="'http://rdaregistry.info/Elements/m/datatype/P30165'"/>
                              <xsl:with-param name="select" select="."/>
                           </xsl:call-template>
                        </xsl:copy>
                     </xsl:if>
                  </xsl:for-each>
               </xsl:copy>
            </xsl:for-each>
            <xsl:for-each select="$record/*:datafield[@tag='500'][*:subfield/@code = ('a')]">
               <xsl:copy>
                  <xsl:call-template name="copy-attributes"/>
                  <xsl:for-each select="*:subfield[@code = ('a')]">
                     <xsl:if test="@code = 'a'">
                        <xsl:copy>
                           <xsl:call-template name="copy-content">
                              <xsl:with-param name="type"
                                               select="'http://rdaregistry.info/Elements/m/datatype/P30137'"/>
                              <xsl:with-param name="select" select="."/>
                           </xsl:call-template>
                        </xsl:copy>
                     </xsl:if>
                  </xsl:for-each>
               </xsl:copy>
            </xsl:for-each>
            <xsl:for-each select="$record/*:datafield[@tag='505'][*:subfield/@code = ('a','g','r','t')]">
               <xsl:copy>
                  <xsl:call-template name="copy-attributes"/>
                  <xsl:for-each select="*:subfield[@code = ('a','g','r','t')]">
                     <xsl:if test="@code = 'a'">
                        <xsl:copy>
                           <xsl:call-template name="copy-content">
                              <xsl:with-param name="type"
                                               select="'http://rdaregistry.info/Elements/m/datatype/P30137'"/>
                              <xsl:with-param name="select" select="."/>
                           </xsl:call-template>
                        </xsl:copy>
                     </xsl:if>
                     <xsl:if test="@code = 'g'">
                        <xsl:copy>
                           <xsl:call-template name="copy-content">
                              <xsl:with-param name="type"
                                               select="'http://rdaregistry.info/Elements/m/datatype/P30137'"/>
                              <xsl:with-param name="select" select="."/>
                           </xsl:call-template>
                        </xsl:copy>
                     </xsl:if>
                     <xsl:if test="@code = 'r'">
                        <xsl:copy>
                           <xsl:call-template name="copy-content">
                              <xsl:with-param name="type"
                                               select="'http://rdaregistry.info/Elements/m/datatype/P30137'"/>
                              <xsl:with-param name="select" select="."/>
                           </xsl:call-template>
                        </xsl:copy>
                     </xsl:if>
                     <xsl:if test="@code = 't'">
                        <xsl:copy>
                           <xsl:call-template name="copy-content">
                              <xsl:with-param name="type"
                                               select="'http://rdaregistry.info/Elements/m/datatype/P30137'"/>
                              <xsl:with-param name="select" select="."/>
                           </xsl:call-template>
                        </xsl:copy>
                     </xsl:if>
                  </xsl:for-each>
               </xsl:copy>
            </xsl:for-each>
            <xsl:for-each select="$record/*:datafield[@tag='773'][*:subfield/@code = ('t')]">
               <xsl:copy>
                  <xsl:call-template name="copy-attributes"/>
                  <xsl:for-each select="*:subfield[@code = ('t')]">
                     <xsl:if test="@code = 't' and . ne $record/*:datafield[@tag='245']/*:subfield[@code='a']">
                        <xsl:copy>
                           <xsl:call-template name="copy-content">
                              <xsl:with-param name="type"
                                               select="'http://rdaregistry.info/Elements/m/datatype/P30050'"/>
                              <xsl:with-param name="select"
                                               select="string-join((frbrizer:trim(.), frbrizer:trim(../*:subfield[@code='d']), frbrizer:trim(../*:subfield[@code='g'])), ', ') || '.'"/>
                           </xsl:call-template>
                        </xsl:copy>
                     </xsl:if>
                  </xsl:for-each>
               </xsl:copy>
            </xsl:for-each>
            <xsl:for-each select="$record/node()[@tag=('100','110','111','700','710','711')][exists(*:subfield[@code = '1']/starts-with(., 'http')) and not(*:subfield/@code = 't')]">
               <xsl:variable name="target_template_name" select="'MARC21-100700Person'"/>
               <xsl:variable name="target_tag_value" select="'100, 110, 111, 700, 710, 711'"/>
               <xsl:variable name="target_field"
                              select="(ancestor-or-self::*:datafield, ancestor-or-self::*:controlfield)"/>
               <xsl:variable name="target_field_position"
                              as="xs:string"
                              select="string(position())"/>
               <xsl:for-each select="node()[@code=('4')][starts-with(., 'http')]">
                  <xsl:variable name="target_subfield" select="."/>
                  <xsl:variable name="target_subfield_code"
                                 as="xs:string"
                                 select="$target_subfield/@code"/>
                  <xsl:variable name="target_subfield_position"
                                 as="xs:string"
                                 select="string(position())"/>
                  <xsl:if test="(starts-with($target_subfield, 'http://rdaregistry.info/Elements/m/') and frbrizer:linked($anchor_field, $target_field, false()))">
                     <frbrizer:relationship>
                        <xsl:attribute name="type" select="$target_subfield"/>
                        <xsl:attribute name="href"
                                        select="string-join(($record/@id,$target_template_name,$target_tag_value,$target_subfield_code,$target_field_position,$target_subfield_position), ':')"/>
                        <xsl:if test="$include_internal_key">
                           <xsl:attribute name="intkey"
                                           select="string-join(($record/@id,$target_template_name,$target_tag_value,$target_subfield_code,$target_field_position,$target_subfield_position), ':')"/>
                        </xsl:if>
                     </frbrizer:relationship>
                  </xsl:if>
               </xsl:for-each>
            </xsl:for-each>
            <xsl:for-each select="$record/node()[@tag=('130','240')][count($record/*:datafield[@tag='700' and @ind2 = '2' and *:subfield/@code = 't']) = 0]">
               <xsl:variable name="target_template_name" select="'MARC21-130240-Expression'"/>
               <xsl:variable name="target_tag_value" select="'130, 240'"/>
               <xsl:variable name="target_field"
                              select="(ancestor-or-self::*:datafield, ancestor-or-self::*:controlfield)"/>
               <xsl:variable name="target_field_position"
                              as="xs:string"
                              select="string(position())"/>
               <xsl:for-each select="node()[@code=('1')][starts-with(., 'http')]">
                  <xsl:variable name="target_subfield" select="."/>
                  <xsl:variable name="target_subfield_code"
                                 as="xs:string"
                                 select="$target_subfield/@code"/>
                  <xsl:variable name="target_subfield_position"
                                 as="xs:string"
                                 select="string(position())"/>
                  <frbrizer:relationship>
                     <xsl:attribute name="type" select="'http://rdaregistry.info/Elements/m/object/P30139'"/>
                     <xsl:attribute name="href"
                                     select="string-join(($record/@id,$target_template_name,$target_tag_value,$target_subfield_code,$target_field_position,$target_subfield_position), ':')"/>
                     <xsl:if test="$include_internal_key">
                        <xsl:attribute name="intkey"
                                        select="string-join(($record/@id,$target_template_name,$target_tag_value,$target_subfield_code,$target_field_position,$target_subfield_position), ':')"/>
                     </xsl:if>
                  </frbrizer:relationship>
               </xsl:for-each>
            </xsl:for-each>
            <xsl:for-each select="$record/node()[@tag=('700','710','711','730')][exists(*:subfield[@code = '1']/starts-with(., 'http'))  and  @ind2='2' and (if (@tag eq '730') then true() else *:subfield/@code = 't')]">
               <xsl:variable name="target_template_name" select="'MARC21-700-Expression-Analytical'"/>
               <xsl:variable name="target_tag_value" select="'700, 710, 711, 730'"/>
               <xsl:variable name="target_field"
                              select="(ancestor-or-self::*:datafield, ancestor-or-self::*:controlfield)"/>
               <xsl:variable name="target_field_position"
                              as="xs:string"
                              select="string(position())"/>
               <frbrizer:relationship>
                  <xsl:attribute name="type" select="'http://rdaregistry.info/Elements/m/object/P30139'"/>
                  <xsl:attribute name="href"
                                  select="string-join(($record/@id,$target_template_name,$target_tag_value,$target_field_position), ':')"/>
                  <xsl:if test="$include_internal_key">
                     <xsl:attribute name="intkey"
                                     select="string-join(($record/@id,$target_template_name,$target_tag_value,$target_field_position), ':')"/>
                  </xsl:if>
               </frbrizer:relationship>
            </xsl:for-each>
            <xsl:for-each select="$record/node()[@tag=('337')]">
               <xsl:variable name="target_template_name" select="'MARC337'"/>
               <xsl:variable name="target_tag_value" select="'337'"/>
               <xsl:variable name="target_field"
                              select="(ancestor-or-self::*:datafield, ancestor-or-self::*:controlfield)"/>
               <xsl:variable name="target_field_position"
                              as="xs:string"
                              select="string(position())"/>
               <xsl:for-each select="node()[@code=('0')][starts-with(., 'http')]">
                  <xsl:variable name="target_subfield" select="."/>
                  <xsl:variable name="target_subfield_code"
                                 as="xs:string"
                                 select="$target_subfield/@code"/>
                  <xsl:variable name="target_subfield_position"
                                 as="xs:string"
                                 select="string(position())"/>
                  <xsl:if test="(frbrizer:linked($anchor_field, $target_field, false()))">
                     <frbrizer:relationship>
                        <xsl:attribute name="type"
                                        select="'http://rdaregistry.info/Elements/m/datatype/P30002'"/>
                        <xsl:attribute name="href"
                                        select="string-join(($record/@id,$target_template_name,$target_tag_value,$target_subfield_code,$target_field_position,$target_subfield_position), ':')"/>
                        <xsl:if test="$include_internal_key">
                           <xsl:attribute name="intkey"
                                           select="string-join(($record/@id,$target_template_name,$target_tag_value,$target_subfield_code,$target_field_position,$target_subfield_position), ':')"/>
                        </xsl:if>
                     </frbrizer:relationship>
                  </xsl:if>
               </xsl:for-each>
            </xsl:for-each>
            <xsl:for-each select="$record/node()[@tag=('338')]">
               <xsl:variable name="target_template_name" select="'MARC338'"/>
               <xsl:variable name="target_tag_value" select="'338'"/>
               <xsl:variable name="target_field"
                              select="(ancestor-or-self::*:datafield, ancestor-or-self::*:controlfield)"/>
               <xsl:variable name="target_field_position"
                              as="xs:string"
                              select="string(position())"/>
               <xsl:for-each select="node()[@code=('0')][starts-with(., 'http')]">
                  <xsl:variable name="target_subfield" select="."/>
                  <xsl:variable name="target_subfield_code"
                                 as="xs:string"
                                 select="$target_subfield/@code"/>
                  <xsl:variable name="target_subfield_position"
                                 as="xs:string"
                                 select="string(position())"/>
                  <xsl:if test="(frbrizer:linked($anchor_field, $target_field, false()))">
                     <frbrizer:relationship>
                        <xsl:attribute name="type"
                                        select="'http://rdaregistry.info/Elements/m/datatype/P30001'"/>
                        <xsl:attribute name="href"
                                        select="string-join(($record/@id,$target_template_name,$target_tag_value,$target_subfield_code,$target_field_position,$target_subfield_position), ':')"/>
                        <xsl:if test="$include_internal_key">
                           <xsl:attribute name="intkey"
                                           select="string-join(($record/@id,$target_template_name,$target_tag_value,$target_subfield_code,$target_field_position,$target_subfield_position), ':')"/>
                        </xsl:if>
                     </frbrizer:relationship>
                  </xsl:if>
               </xsl:for-each>
            </xsl:for-each>
         </xsl:element>
      </xsl:for-each>
   </xsl:template>
   <xsl:template name="MARC21-600-Person">
      <xsl:variable name="this_template_name" select="'MARC21-600-Person'"/>
      <xsl:variable name="tag" as="xs:string" select="'600, 610, 611'"/>
      <xsl:variable name="record" select="."/>
      <xsl:variable name="marcid" select="*:controlfield[@tag='001']"/>
      <xsl:for-each select="node()[@tag=('600','610','611')][exists(*:subfield[@code = '1']/starts-with(., 'http')) and not(*:subfield/@code = 't')]">
         <xsl:variable name="this_field"
                        select="(ancestor-or-self::*:datafield, ancestor-or-self::*:controlfield)"/>
         <xsl:variable name="this"
                        select="(ancestor-or-self::*:datafield, ancestor-or-self::*:controlfield)"/>
         <xsl:variable name="anchor_field"
                        select="(ancestor-or-self::*:datafield, ancestor-or-self::*:controlfield)"/>
         <xsl:variable name="anchor"
                        as="xs:string"
                        select="(ancestor-or-self::*:datafield, ancestor-or-self::*:controlfield)"/>
         <xsl:variable name="this_field_position"
                        as="xs:string"
                        select="string(position())"/>
         <xsl:element name="{name(ancestor-or-self::*:record)}"
                       namespace="{namespace-uri(ancestor-or-self::*:record)}">
            <xsl:attribute name="id"
                            select="string-join(($record/@id,$this_template_name,$tag,$this_field_position), ':')"/>
            <xsl:attribute name="type"
                            select="if ($this_field/@tag = '600') then 'http://rdaregistry.info/Elements/c/C10002' else if ($this_field/@tag = '610') then 'http://rdaregistry.info/Elements/c/C10005' else if ($this_field/@tag = '611') then 'http://rdaregistry.info/Elements/c/C10011' else 'http://rdaregistry.info/Elements/c/C10002'"/>
            <xsl:attribute name="templatename" select="$this_template_name"/>
            <xsl:for-each select="$record/*:datafield[@tag='600'][. eq $this_field][*:subfield/@code = ('a','d','1')]">
               <xsl:copy>
                  <xsl:call-template name="copy-attributes"/>
                  <xsl:for-each select="*:subfield[@code = ('a','d','1')]">
                     <xsl:if test="@code = 'a'">
                        <xsl:copy>
                           <xsl:call-template name="copy-content">
                              <xsl:with-param name="type" select="'http://www.w3.org/2000/01/rdf-schema#label'"/>
                              <xsl:with-param name="select" select="frbrizer:trim(.)"/>
                           </xsl:call-template>
                        </xsl:copy>
                     </xsl:if>
                     <xsl:if test="@code = 'a'">
                        <xsl:copy>
                           <xsl:call-template name="copy-content">
                              <xsl:with-param name="type"
                                               select="'http://rdaregistry.info/Elements/a/datatype/P50385'"/>
                              <xsl:with-param name="select" select="frbrizer:trim(.)"/>
                           </xsl:call-template>
                        </xsl:copy>
                     </xsl:if>
                     <xsl:if test="@code = 'd'">
                        <xsl:copy>
                           <xsl:call-template name="copy-content">
                              <xsl:with-param name="type"
                                               select="'http://rdaregistry.info/Elements/a/datatype/P50339'"/>
                              <xsl:with-param name="select" select="frbrizer:trim(.)"/>
                           </xsl:call-template>
                        </xsl:copy>
                     </xsl:if>
                     <xsl:if test="@code = '1'">
                        <xsl:copy>
                           <xsl:call-template name="copy-content">
                              <xsl:with-param name="type"
                                               select="'http://rdaregistry.info/Elements/x/datatype/P00018'"/>
                              <xsl:with-param name="select" select="."/>
                           </xsl:call-template>
                        </xsl:copy>
                     </xsl:if>
                  </xsl:for-each>
               </xsl:copy>
            </xsl:for-each>
            <xsl:for-each select="$record/*:datafield[@tag='610'][. eq $this_field][*:subfield/@code = ('a','d','1')]">
               <xsl:copy>
                  <xsl:call-template name="copy-attributes"/>
                  <xsl:for-each select="*:subfield[@code = ('a','d','1')]">
                     <xsl:if test="@code = 'a'">
                        <xsl:copy>
                           <xsl:call-template name="copy-content">
                              <xsl:with-param name="type" select="'http://www.w3.org/2000/01/rdf-schema#label'"/>
                              <xsl:with-param name="select" select="frbrizer:trim(.)"/>
                           </xsl:call-template>
                        </xsl:copy>
                     </xsl:if>
                     <xsl:if test="@code = 'a'">
                        <xsl:copy>
                           <xsl:call-template name="copy-content">
                              <xsl:with-param name="type"
                                               select="'http://rdaregistry.info/Elements/a/datatype/P50385'"/>
                              <xsl:with-param name="select" select="frbrizer:trim(.)"/>
                           </xsl:call-template>
                        </xsl:copy>
                     </xsl:if>
                     <xsl:if test="@code = 'd'">
                        <xsl:copy>
                           <xsl:call-template name="copy-content">
                              <xsl:with-param name="type"
                                               select="'http://rdaregistry.info/Elements/a/datatype/P50339'"/>
                              <xsl:with-param name="select" select="frbrizer:trim(.)"/>
                           </xsl:call-template>
                        </xsl:copy>
                     </xsl:if>
                     <xsl:if test="@code = '1'">
                        <xsl:copy>
                           <xsl:call-template name="copy-content">
                              <xsl:with-param name="type"
                                               select="'http://rdaregistry.info/Elements/x/datatype/P00018'"/>
                              <xsl:with-param name="select" select="."/>
                           </xsl:call-template>
                        </xsl:copy>
                     </xsl:if>
                  </xsl:for-each>
               </xsl:copy>
            </xsl:for-each>
            <xsl:for-each select="$record/*:datafield[@tag='611'][. eq $this_field][*:subfield/@code = ('a','d','1')]">
               <xsl:copy>
                  <xsl:call-template name="copy-attributes"/>
                  <xsl:for-each select="*:subfield[@code = ('a','d','1')]">
                     <xsl:if test="@code = 'a'">
                        <xsl:copy>
                           <xsl:call-template name="copy-content">
                              <xsl:with-param name="type" select="'http://www.w3.org/2000/01/rdf-schema#label'"/>
                              <xsl:with-param name="select" select="frbrizer:trim(.)"/>
                           </xsl:call-template>
                        </xsl:copy>
                     </xsl:if>
                     <xsl:if test="@code = 'a'">
                        <xsl:copy>
                           <xsl:call-template name="copy-content">
                              <xsl:with-param name="type"
                                               select="'http://rdaregistry.info/Elements/a/datatype/P50385'"/>
                              <xsl:with-param name="select" select="frbrizer:trim(.)"/>
                           </xsl:call-template>
                        </xsl:copy>
                     </xsl:if>
                     <xsl:if test="@code = 'd'">
                        <xsl:copy>
                           <xsl:call-template name="copy-content">
                              <xsl:with-param name="type"
                                               select="'http://rdaregistry.info/Elements/a/datatype/P50339'"/>
                              <xsl:with-param name="select" select="frbrizer:trim(.)"/>
                           </xsl:call-template>
                        </xsl:copy>
                     </xsl:if>
                     <xsl:if test="@code = '1'">
                        <xsl:copy>
                           <xsl:call-template name="copy-content">
                              <xsl:with-param name="type"
                                               select="'http://rdaregistry.info/Elements/x/datatype/P00018'"/>
                              <xsl:with-param name="select" select="."/>
                           </xsl:call-template>
                        </xsl:copy>
                     </xsl:if>
                  </xsl:for-each>
               </xsl:copy>
            </xsl:for-each>
         </xsl:element>
      </xsl:for-each>
   </xsl:template>
   <xsl:template name="MARC21-6XX-Work">
      <xsl:variable name="this_template_name" select="'MARC21-6XX-Work'"/>
      <xsl:variable name="tag" as="xs:string" select="'600, 610, 611, 630'"/>
      <xsl:variable name="code" as="xs:string" select="'1'"/>
      <xsl:variable name="record" select="."/>
      <xsl:variable name="marcid" select="*:controlfield[@tag='001']"/>
      <xsl:for-each select="node()[@tag=('600','610','611','630')][*:subfield/@code = '1' and  (if (@tag eq '630') then true() else *:subfield/@code = 't')]">
         <xsl:variable name="this_field"
                        select="(ancestor-or-self::*:datafield, ancestor-or-self::*:controlfield)"/>
         <xsl:variable name="this"
                        select="(ancestor-or-self::*:datafield, ancestor-or-self::*:controlfield)"/>
         <xsl:variable name="anchor_field"
                        select="(ancestor-or-self::*:datafield, ancestor-or-self::*:controlfield)"/>
         <xsl:variable name="anchor"
                        as="xs:string"
                        select="(ancestor-or-self::*:datafield, ancestor-or-self::*:controlfield)"/>
         <xsl:variable name="this_field_position"
                        as="xs:string"
                        select="string(position())"/>
         <xsl:for-each select="node()[@code=('1')][starts-with(., 'http')]">
            <xsl:variable name="this_subfield" select="(ancestor-or-self::*:subfield)"/>
            <xsl:variable name="anchor_subfield" select="(ancestor-or-self::*:subfield)"/>
            <xsl:variable name="this_subfield_code"
                           as="xs:string"
                           select="$this_subfield/@code"/>
            <xsl:variable name="anchor_subfield_code"
                           as="xs:string"
                           select="$this_subfield/@code"/>
            <xsl:variable name="this_subfield_position"
                           as="xs:string"
                           select="string(position())"/>
            <xsl:element name="{name(ancestor-or-self::*:record)}"
                          namespace="{namespace-uri(ancestor-or-self::*:record)}">
               <xsl:attribute name="id"
                               select="string-join(($record/@id,$this_template_name,$tag,$this_subfield_code,$this_field_position,$this_subfield_position), ':')"/>
               <xsl:attribute name="type" select="'http://rdaregistry.info/Elements/c/C10001'"/>
               <xsl:attribute name="templatename" select="$this_template_name"/>
               <xsl:for-each select="$record/*:datafield[@tag='600'][. eq $this_field][*:subfield/@code = ('t','f','n','1')]">
                  <xsl:copy>
                     <xsl:call-template name="copy-attributes"/>
                     <xsl:for-each select="*:subfield[@code = ('t','f','n','1')]">
                        <xsl:if test="@code = 't'">
                           <xsl:copy>
                              <xsl:call-template name="copy-content">
                                 <xsl:with-param name="type" select="'http://www.w3.org/2000/01/rdf-schema#label'"/>
                                 <xsl:with-param name="select"
                                                  select="frbrizer:trim(.) || ' (' || ../*:subfield[@code='a']/replace(., '[\s,/:=]+$', '') || ')'"/>
                              </xsl:call-template>
                           </xsl:copy>
                        </xsl:if>
                        <xsl:if test="@code = 't'">
                           <xsl:copy>
                              <xsl:call-template name="copy-content">
                                 <xsl:with-param name="type" select="'http://www.w3.org/2000/01/rdf-schema#label'"/>
                                 <xsl:with-param name="select" select="frbrizer:trim(.)"/>
                              </xsl:call-template>
                           </xsl:copy>
                        </xsl:if>
                        <xsl:if test="@code = 't'">
                           <xsl:copy>
                              <xsl:call-template name="copy-content">
                                 <xsl:with-param name="type"
                                                  select="'http://rdaregistry.info/Elements/w/datatype/P10088'"/>
                                 <xsl:with-param name="select"
                                                  select="string-join((frbrizer:trim(.), frbrizer:trim(../*:subfield[@code = 'p'])), ' : ')"/>
                              </xsl:call-template>
                           </xsl:copy>
                        </xsl:if>
                        <xsl:if test="@code = 'f'">
                           <xsl:copy>
                              <xsl:call-template name="copy-content">
                                 <xsl:with-param name="type"
                                                  select="'http://rdaregistry.info/Elements/w/datatype/P10219'"/>
                                 <xsl:with-param name="select" select="."/>
                              </xsl:call-template>
                           </xsl:copy>
                        </xsl:if>
                        <xsl:if test="@code = 'n'">
                           <xsl:copy>
                              <xsl:call-template name="copy-content">
                                 <xsl:with-param name="type"
                                                  select="'http://rdaregistry.info/Elements/w/datatype/P10012'"/>
                                 <xsl:with-param name="select" select="."/>
                              </xsl:call-template>
                           </xsl:copy>
                        </xsl:if>
                        <xsl:if test="@code = '1'">
                           <xsl:copy>
                              <xsl:call-template name="copy-content">
                                 <xsl:with-param name="type"
                                                  select="'http://rdaregistry.info/Elements/x/datatype/P00018'"/>
                                 <xsl:with-param name="select" select="."/>
                              </xsl:call-template>
                           </xsl:copy>
                        </xsl:if>
                     </xsl:for-each>
                  </xsl:copy>
               </xsl:for-each>
               <xsl:for-each select="$record/*:datafield[@tag='610'][. eq $this_field][*:subfield/@code = ('t','f','n','1')]">
                  <xsl:copy>
                     <xsl:call-template name="copy-attributes"/>
                     <xsl:for-each select="*:subfield[@code = ('t','f','n','1')]">
                        <xsl:if test="@code = 't'">
                           <xsl:copy>
                              <xsl:call-template name="copy-content">
                                 <xsl:with-param name="type" select="'http://www.w3.org/2000/01/rdf-schema#label'"/>
                                 <xsl:with-param name="select" select="frbrizer:trim(.)"/>
                              </xsl:call-template>
                           </xsl:copy>
                        </xsl:if>
                        <xsl:if test="@code = 't'">
                           <xsl:copy>
                              <xsl:call-template name="copy-content">
                                 <xsl:with-param name="type"
                                                  select="'http://rdaregistry.info/Elements/w/datatype/P10088'"/>
                                 <xsl:with-param name="select"
                                                  select="string-join((frbrizer:trim(.), frbrizer:trim(../*:subfield[@code = 'p'])), ' : ')"/>
                              </xsl:call-template>
                           </xsl:copy>
                        </xsl:if>
                        <xsl:if test="@code = 'f'">
                           <xsl:copy>
                              <xsl:call-template name="copy-content">
                                 <xsl:with-param name="type"
                                                  select="'http://rdaregistry.info/Elements/w/datatype/P10219'"/>
                                 <xsl:with-param name="select" select="."/>
                              </xsl:call-template>
                           </xsl:copy>
                        </xsl:if>
                        <xsl:if test="@code = 'n'">
                           <xsl:copy>
                              <xsl:call-template name="copy-content">
                                 <xsl:with-param name="type"
                                                  select="'http://rdaregistry.info/Elements/w/datatype/P10012'"/>
                                 <xsl:with-param name="select" select="."/>
                              </xsl:call-template>
                           </xsl:copy>
                        </xsl:if>
                        <xsl:if test="@code = '1'">
                           <xsl:copy>
                              <xsl:call-template name="copy-content">
                                 <xsl:with-param name="type"
                                                  select="'http://rdaregistry.info/Elements/x/datatype/P00018'"/>
                                 <xsl:with-param name="select" select="."/>
                              </xsl:call-template>
                           </xsl:copy>
                        </xsl:if>
                     </xsl:for-each>
                  </xsl:copy>
               </xsl:for-each>
               <xsl:for-each select="$record/*:datafield[@tag='611'][. eq $this_field][*:subfield/@code = ('t','f','n','1')]">
                  <xsl:copy>
                     <xsl:call-template name="copy-attributes"/>
                     <xsl:for-each select="*:subfield[@code = ('t','f','n','1')]">
                        <xsl:if test="@code = 't'">
                           <xsl:copy>
                              <xsl:call-template name="copy-content">
                                 <xsl:with-param name="type" select="'http://www.w3.org/2000/01/rdf-schema#label'"/>
                                 <xsl:with-param name="select" select="frbrizer:trim(.)"/>
                              </xsl:call-template>
                           </xsl:copy>
                        </xsl:if>
                        <xsl:if test="@code = 't'">
                           <xsl:copy>
                              <xsl:call-template name="copy-content">
                                 <xsl:with-param name="type"
                                                  select="'http://rdaregistry.info/Elements/w/datatype/P10088'"/>
                                 <xsl:with-param name="select"
                                                  select="string-join((frbrizer:trim(.), frbrizer:trim(../*:subfield[@code = 'p'])), ' : ')"/>
                              </xsl:call-template>
                           </xsl:copy>
                        </xsl:if>
                        <xsl:if test="@code = 'f'">
                           <xsl:copy>
                              <xsl:call-template name="copy-content">
                                 <xsl:with-param name="type"
                                                  select="'http://rdaregistry.info/Elements/w/datatype/P10219'"/>
                                 <xsl:with-param name="select" select="."/>
                              </xsl:call-template>
                           </xsl:copy>
                        </xsl:if>
                        <xsl:if test="@code = 'n'">
                           <xsl:copy>
                              <xsl:call-template name="copy-content">
                                 <xsl:with-param name="type"
                                                  select="'http://rdaregistry.info/Elements/w/datatype/P10012'"/>
                                 <xsl:with-param name="select" select="."/>
                              </xsl:call-template>
                           </xsl:copy>
                        </xsl:if>
                        <xsl:if test="@code = '1'">
                           <xsl:copy>
                              <xsl:call-template name="copy-content">
                                 <xsl:with-param name="type"
                                                  select="'http://rdaregistry.info/Elements/x/datatype/P00018'"/>
                                 <xsl:with-param name="select" select="."/>
                              </xsl:call-template>
                           </xsl:copy>
                        </xsl:if>
                     </xsl:for-each>
                  </xsl:copy>
               </xsl:for-each>
               <xsl:for-each select="$record/*:datafield[@tag='630'][. eq $this_field][*:subfield/@code = ('a','f','n','1')]">
                  <xsl:copy>
                     <xsl:call-template name="copy-attributes"/>
                     <xsl:for-each select="*:subfield[@code = ('a','f','n','1')]">
                        <xsl:if test="@code = 'a'">
                           <xsl:copy>
                              <xsl:call-template name="copy-content">
                                 <xsl:with-param name="type" select="'http://www.w3.org/2000/01/rdf-schema#label'"/>
                                 <xsl:with-param name="select" select="frbrizer:trim(.)"/>
                              </xsl:call-template>
                           </xsl:copy>
                        </xsl:if>
                        <xsl:if test="@code = 'a'">
                           <xsl:copy>
                              <xsl:call-template name="copy-content">
                                 <xsl:with-param name="type"
                                                  select="'http://rdaregistry.info/Elements/w/datatype/P10088'"/>
                                 <xsl:with-param name="select"
                                                  select="string-join((frbrizer:trim(.), frbrizer:trim(../*:subfield[@code = 'p'])), ' : ')"/>
                              </xsl:call-template>
                           </xsl:copy>
                        </xsl:if>
                        <xsl:if test="@code = 'f'">
                           <xsl:copy>
                              <xsl:call-template name="copy-content">
                                 <xsl:with-param name="type"
                                                  select="'http://rdaregistry.info/Elements/w/datatype/P10219'"/>
                                 <xsl:with-param name="select" select="."/>
                              </xsl:call-template>
                           </xsl:copy>
                        </xsl:if>
                        <xsl:if test="@code = 'n'">
                           <xsl:copy>
                              <xsl:call-template name="copy-content">
                                 <xsl:with-param name="type"
                                                  select="'http://rdaregistry.info/Elements/w/datatype/P10012'"/>
                                 <xsl:with-param name="select" select="."/>
                              </xsl:call-template>
                           </xsl:copy>
                        </xsl:if>
                        <xsl:if test="@code = '1'">
                           <xsl:copy>
                              <xsl:call-template name="copy-content">
                                 <xsl:with-param name="type"
                                                  select="'http://rdaregistry.info/Elements/x/datatype/P00018'"/>
                                 <xsl:with-param name="select" select="."/>
                              </xsl:call-template>
                           </xsl:copy>
                        </xsl:if>
                     </xsl:for-each>
                  </xsl:copy>
               </xsl:for-each>
            </xsl:element>
         </xsl:for-each>
      </xsl:for-each>
   </xsl:template>
   <xsl:template name="MARC21-700-Expression-Analytical">
      <xsl:variable name="this_template_name" select="'MARC21-700-Expression-Analytical'"/>
      <xsl:variable name="tag" as="xs:string" select="'700, 710, 711, 730'"/>
      <xsl:variable name="record" select="."/>
      <xsl:variable name="marcid" select="*:controlfield[@tag='001']"/>
      <xsl:for-each select="node()[@tag=('700','710','711','730')][exists(*:subfield[@code = '1']/starts-with(., 'http'))  and  @ind2='2' and (if (@tag eq '730') then true() else *:subfield/@code = 't')]">
         <xsl:variable name="this_field"
                        select="(ancestor-or-self::*:datafield, ancestor-or-self::*:controlfield)"/>
         <xsl:variable name="this"
                        select="(ancestor-or-self::*:datafield, ancestor-or-self::*:controlfield)"/>
         <xsl:variable name="anchor_field"
                        select="(ancestor-or-self::*:datafield, ancestor-or-self::*:controlfield)"/>
         <xsl:variable name="anchor"
                        as="xs:string"
                        select="(ancestor-or-self::*:datafield, ancestor-or-self::*:controlfield)"/>
         <xsl:variable name="this_field_position"
                        as="xs:string"
                        select="string(position())"/>
         <xsl:element name="{name(ancestor-or-self::*:record)}"
                       namespace="{namespace-uri(ancestor-or-self::*:record)}">
            <xsl:attribute name="id"
                            select="string-join(($record/@id,$this_template_name,$tag,$this_field_position), ':')"/>
            <xsl:attribute name="type" select="'http://rdaregistry.info/Elements/c/C10006'"/>
            <xsl:attribute name="templatename" select="$this_template_name"/>
            <xsl:for-each select="$record/*:datafield[@tag='700'][. eq $this_field][*:subfield/@code = ('t','l')]">
               <xsl:copy>
                  <xsl:call-template name="copy-attributes"/>
                  <xsl:for-each select="*:subfield[@code = ('t','l')]">
                     <xsl:if test="@code = 't'">
                        <xsl:copy>
                           <xsl:call-template name="copy-content">
                              <xsl:with-param name="type" select="'http://www.w3.org/2000/01/rdf-schema#label'"/>
                              <xsl:with-param name="select"
                                               select="string-join((frbrizer:trim(.), $record/*:datafield[@tag='041']/*:subfield[@code=('a', 'd')][1], $record/*:datafield[@tag='336']/*:subfield[@code='a'][1]), ' / ')"/>
                           </xsl:call-template>
                        </xsl:copy>
                     </xsl:if>
                     <xsl:if test="@code = 'l'">
                        <xsl:copy>
                           <xsl:call-template name="copy-content">
                              <xsl:with-param name="type"
                                               select="'http://rdaregistry.info/Elements/e/datatype/P20006'"/>
                              <xsl:with-param name="select" select="lower-case(.)"/>
                           </xsl:call-template>
                        </xsl:copy>
                     </xsl:if>
                     <xsl:if test="@code = 't'">
                        <xsl:copy>
                           <xsl:call-template name="copy-content">
                              <xsl:with-param name="type"
                                               select="'http://rdaregistry.info/Elements/e/datatype/P20312'"/>
                              <xsl:with-param name="select" select="frbrizer:trim(.)"/>
                           </xsl:call-template>
                        </xsl:copy>
                     </xsl:if>
                  </xsl:for-each>
               </xsl:copy>
            </xsl:for-each>
            <xsl:for-each select="$record/*:datafield[@tag='710'][. eq $this_field][*:subfield/@code = ('t','l')]">
               <xsl:copy>
                  <xsl:call-template name="copy-attributes"/>
                  <xsl:for-each select="*:subfield[@code = ('t','l')]">
                     <xsl:if test="@code = 't'">
                        <xsl:copy>
                           <xsl:call-template name="copy-content">
                              <xsl:with-param name="type" select="'http://www.w3.org/2000/01/rdf-schema#label'"/>
                              <xsl:with-param name="select" select="frbrizer:trim(.)"/>
                           </xsl:call-template>
                        </xsl:copy>
                     </xsl:if>
                     <xsl:if test="@code = 'l'">
                        <xsl:copy>
                           <xsl:call-template name="copy-content">
                              <xsl:with-param name="type"
                                               select="'http://rdaregistry.info/Elements/e/datatype/P20006'"/>
                              <xsl:with-param name="select" select="lower-case(.)"/>
                           </xsl:call-template>
                        </xsl:copy>
                     </xsl:if>
                     <xsl:if test="@code = 't'">
                        <xsl:copy>
                           <xsl:call-template name="copy-content">
                              <xsl:with-param name="type"
                                               select="'http://rdaregistry.info/Elements/e/datatype/P20312'"/>
                              <xsl:with-param name="select" select="frbrizer:trim(.)"/>
                           </xsl:call-template>
                        </xsl:copy>
                     </xsl:if>
                  </xsl:for-each>
               </xsl:copy>
            </xsl:for-each>
            <xsl:for-each select="$record/*:datafield[@tag='711'][. eq $this_field][*:subfield/@code = ('t','l')]">
               <xsl:copy>
                  <xsl:call-template name="copy-attributes"/>
                  <xsl:for-each select="*:subfield[@code = ('t','l')]">
                     <xsl:if test="@code = 't'">
                        <xsl:copy>
                           <xsl:call-template name="copy-content">
                              <xsl:with-param name="type" select="'http://www.w3.org/2000/01/rdf-schema#label'"/>
                              <xsl:with-param name="select" select="frbrizer:trim(.)"/>
                           </xsl:call-template>
                        </xsl:copy>
                     </xsl:if>
                     <xsl:if test="@code = 'l'">
                        <xsl:copy>
                           <xsl:call-template name="copy-content">
                              <xsl:with-param name="type"
                                               select="'http://rdaregistry.info/Elements/e/datatype/P20006'"/>
                              <xsl:with-param name="select" select="lower-case(.)"/>
                           </xsl:call-template>
                        </xsl:copy>
                     </xsl:if>
                     <xsl:if test="@code = 't'">
                        <xsl:copy>
                           <xsl:call-template name="copy-content">
                              <xsl:with-param name="type"
                                               select="'http://rdaregistry.info/Elements/e/datatype/P20312'"/>
                              <xsl:with-param name="select" select="frbrizer:trim(.)"/>
                           </xsl:call-template>
                        </xsl:copy>
                     </xsl:if>
                  </xsl:for-each>
               </xsl:copy>
            </xsl:for-each>
            <xsl:for-each select="$record/*:datafield[@tag='730'][. eq $this_field][*:subfield/@code = ('a','l')]">
               <xsl:copy>
                  <xsl:call-template name="copy-attributes"/>
                  <xsl:for-each select="*:subfield[@code = ('a','l')]">
                     <xsl:if test="@code = 'a'">
                        <xsl:copy>
                           <xsl:call-template name="copy-content">
                              <xsl:with-param name="type" select="'http://www.w3.org/2000/01/rdf-schema#label'"/>
                              <xsl:with-param name="select" select="frbrizer:trim(.)"/>
                           </xsl:call-template>
                        </xsl:copy>
                     </xsl:if>
                     <xsl:if test="@code = 'l'">
                        <xsl:copy>
                           <xsl:call-template name="copy-content">
                              <xsl:with-param name="type"
                                               select="'http://rdaregistry.info/Elements/e/datatype/P20006'"/>
                              <xsl:with-param name="select" select="lower-case(.)"/>
                           </xsl:call-template>
                        </xsl:copy>
                     </xsl:if>
                     <xsl:if test="@code = 'a'">
                        <xsl:copy>
                           <xsl:call-template name="copy-content">
                              <xsl:with-param name="type"
                                               select="'http://rdaregistry.info/Elements/e/datatype/P20312'"/>
                              <xsl:with-param name="select" select="frbrizer:trim(.)"/>
                           </xsl:call-template>
                        </xsl:copy>
                     </xsl:if>
                  </xsl:for-each>
               </xsl:copy>
            </xsl:for-each>
            <xsl:for-each select="$record/*:datafield[@tag='740'][frbrizer:linked($anchor_field, ., true())][*:subfield/@code = ('a')]">
               <xsl:copy>
                  <xsl:call-template name="copy-attributes"/>
                  <xsl:for-each select="*:subfield[@code = ('a')]">
                     <xsl:if test="@code = 'a'">
                        <xsl:copy>
                           <xsl:call-template name="copy-content">
                              <xsl:with-param name="type"
                                               select="'http://rdaregistry.info/Elements/e/datatype/P20315'"/>
                              <xsl:with-param name="select" select="frbrizer:trim(.)"/>
                           </xsl:call-template>
                        </xsl:copy>
                     </xsl:if>
                  </xsl:for-each>
               </xsl:copy>
            </xsl:for-each>
            <xsl:for-each select="$record/node()[@tag=('700','710','711','730')][exists(*:subfield[@code = '1']/starts-with(., 'http'))  and @ind2='2' and (if (@tag eq '730') then true() else *:subfield/@code = 't')]">
               <xsl:variable name="target_template_name" select="'MARC21-700-Work-Analytical'"/>
               <xsl:variable name="target_tag_value" select="'700, 710, 711, 730'"/>
               <xsl:variable name="target_field"
                              select="(ancestor-or-self::*:datafield, ancestor-or-self::*:controlfield)"/>
               <xsl:variable name="target_field_position"
                              as="xs:string"
                              select="string(position())"/>
               <xsl:if test="($target_field = $this_field)">
                  <frbrizer:relationship>
                     <xsl:attribute name="type" select="'http://rdaregistry.info/Elements/e/object/P20231'"/>
                     <xsl:attribute name="href"
                                     select="string-join(($record/@id,$target_template_name,$target_tag_value,$target_field_position), ':')"/>
                     <xsl:if test="$include_internal_key">
                        <xsl:attribute name="intkey"
                                        select="string-join(($record/@id,$target_template_name,$target_tag_value,$target_field_position), ':')"/>
                     </xsl:if>
                  </frbrizer:relationship>
               </xsl:if>
            </xsl:for-each>
            <xsl:for-each select="$record/node()[@tag=('100','110','111','700','710','711')][exists(*:subfield[@code = '1']/starts-with(., 'http')) and not(*:subfield/@code = 't')]">
               <xsl:variable name="target_template_name" select="'MARC21-100700Person'"/>
               <xsl:variable name="target_tag_value" select="'100, 110, 111, 700, 710, 711'"/>
               <xsl:variable name="target_field"
                              select="(ancestor-or-self::*:datafield, ancestor-or-self::*:controlfield)"/>
               <xsl:variable name="target_field_position"
                              as="xs:string"
                              select="string(position())"/>
               <xsl:for-each select="node()[@code=('4')][starts-with(., 'http')]">
                  <xsl:variable name="target_subfield" select="."/>
                  <xsl:variable name="target_subfield_code"
                                 as="xs:string"
                                 select="$target_subfield/@code"/>
                  <xsl:variable name="target_subfield_position"
                                 as="xs:string"
                                 select="string(position())"/>
                  <xsl:if test="(starts-with($target_subfield, 'http://rdaregistry.info/Elements/e/') and frbrizer:linked($anchor_field, $target_field, false()))">
                     <frbrizer:relationship>
                        <xsl:attribute name="type" select="$target_subfield"/>
                        <xsl:attribute name="href"
                                        select="string-join(($record/@id,$target_template_name,$target_tag_value,$target_subfield_code,$target_field_position,$target_subfield_position), ':')"/>
                        <xsl:if test="$include_internal_key">
                           <xsl:attribute name="intkey"
                                           select="string-join(($record/@id,$target_template_name,$target_tag_value,$target_subfield_code,$target_field_position,$target_subfield_position), ':')"/>
                        </xsl:if>
                     </frbrizer:relationship>
                  </xsl:if>
               </xsl:for-each>
            </xsl:for-each>
            <xsl:for-each select="$record/node()[@tag=('008')][string-length(.) eq 40 and matches(substring(., 36, 3), '[a-z][a-z][a-z]')]">
               <xsl:variable name="target_template_name" select="'MARC008language'"/>
               <xsl:variable name="target_tag_value" select="'008'"/>
               <xsl:variable name="target_field"
                              select="(ancestor-or-self::*:datafield, ancestor-or-self::*:controlfield)"/>
               <xsl:variable name="target_field_position"
                              as="xs:string"
                              select="string(position())"/>
               <xsl:if test="(frbrizer:linked($anchor_field, $target_field, false()))">
                  <frbrizer:relationship>
                     <xsl:attribute name="type"
                                     select="'http://rdaregistry.info/Elements/e/datatype/P20006'"/>
                     <xsl:attribute name="href"
                                     select="string-join(($record/@id,$target_template_name,$target_tag_value,$target_field_position), ':')"/>
                     <xsl:if test="$include_internal_key">
                        <xsl:attribute name="intkey"
                                        select="string-join(($record/@id,$target_template_name,$target_tag_value,$target_field_position), ':')"/>
                     </xsl:if>
                  </frbrizer:relationship>
               </xsl:if>
            </xsl:for-each>
            <xsl:for-each select="$record/node()[@tag=('041')]">
               <xsl:variable name="target_template_name" select="'MARC041'"/>
               <xsl:variable name="target_tag_value" select="'041'"/>
               <xsl:variable name="target_field"
                              select="(ancestor-or-self::*:datafield, ancestor-or-self::*:controlfield)"/>
               <xsl:variable name="target_field_position"
                              as="xs:string"
                              select="string(position())"/>
               <xsl:for-each select="node()[@code=('a','d')]">
                  <xsl:variable name="target_subfield" select="."/>
                  <xsl:variable name="target_subfield_code"
                                 as="xs:string"
                                 select="$target_subfield/@code"/>
                  <xsl:variable name="target_subfield_position"
                                 as="xs:string"
                                 select="string(position())"/>
                  <xsl:if test="(frbrizer:linked($anchor_field, $target_field, false()))">
                     <frbrizer:relationship>
                        <xsl:attribute name="type"
                                        select="'http://rdaregistry.info/Elements/e/datatype/P20006'"/>
                        <xsl:attribute name="href"
                                        select="string-join(($record/@id,$target_template_name,$target_tag_value,$target_subfield_code,$target_field_position,$target_subfield_position), ':')"/>
                        <xsl:if test="$include_internal_key">
                           <xsl:attribute name="intkey"
                                           select="string-join(($record/@id,$target_template_name,$target_tag_value,$target_subfield_code,$target_field_position,$target_subfield_position), ':')"/>
                        </xsl:if>
                     </frbrizer:relationship>
                  </xsl:if>
               </xsl:for-each>
            </xsl:for-each>
            <xsl:for-each select="$record/node()[@tag=('041')]">
               <xsl:variable name="target_template_name" select="'MARC041additional'"/>
               <xsl:variable name="target_tag_value" select="'041'"/>
               <xsl:variable name="target_field"
                              select="(ancestor-or-self::*:datafield, ancestor-or-self::*:controlfield)"/>
               <xsl:variable name="target_field_position"
                              as="xs:string"
                              select="string(position())"/>
               <xsl:for-each select="node()[@code=('b','e','f','g','i','j','k','l','m','n','p','q','r','t')]">
                  <xsl:variable name="target_subfield" select="."/>
                  <xsl:variable name="target_subfield_code"
                                 as="xs:string"
                                 select="$target_subfield/@code"/>
                  <xsl:variable name="target_subfield_position"
                                 as="xs:string"
                                 select="string(position())"/>
                  <xsl:if test="(frbrizer:linked($anchor_field, $target_field, false()))">
                     <frbrizer:relationship>
                        <xsl:attribute name="type"
                                        select="'http://rdaregistry.info/Elements/e/datatype/P20065'"/>
                        <xsl:attribute name="href"
                                        select="string-join(($record/@id,$target_template_name,$target_tag_value,$target_subfield_code,$target_field_position,$target_subfield_position), ':')"/>
                        <xsl:if test="$include_internal_key">
                           <xsl:attribute name="intkey"
                                           select="string-join(($record/@id,$target_template_name,$target_tag_value,$target_subfield_code,$target_field_position,$target_subfield_position), ':')"/>
                        </xsl:if>
                     </frbrizer:relationship>
                  </xsl:if>
               </xsl:for-each>
            </xsl:for-each>
            <xsl:for-each select="$record/node()[@tag=('336')]">
               <xsl:variable name="target_template_name" select="'MARC336'"/>
               <xsl:variable name="target_tag_value" select="'336'"/>
               <xsl:variable name="target_field"
                              select="(ancestor-or-self::*:datafield, ancestor-or-self::*:controlfield)"/>
               <xsl:variable name="target_field_position"
                              as="xs:string"
                              select="string(position())"/>
               <xsl:for-each select="node()[@code=('0')][starts-with(., 'http')]">
                  <xsl:variable name="target_subfield" select="."/>
                  <xsl:variable name="target_subfield_code"
                                 as="xs:string"
                                 select="$target_subfield/@code"/>
                  <xsl:variable name="target_subfield_position"
                                 as="xs:string"
                                 select="string(position())"/>
                  <xsl:if test="(frbrizer:linked($anchor_field, $target_field, false()))">
                     <frbrizer:relationship>
                        <xsl:attribute name="type"
                                        select="'http://rdaregistry.info/Elements/e/datatype/P20001'"/>
                        <xsl:attribute name="href"
                                        select="string-join(($record/@id,$target_template_name,$target_tag_value,$target_subfield_code,$target_field_position,$target_subfield_position), ':')"/>
                        <xsl:if test="$include_internal_key">
                           <xsl:attribute name="intkey"
                                           select="string-join(($record/@id,$target_template_name,$target_tag_value,$target_subfield_code,$target_field_position,$target_subfield_position), ':')"/>
                        </xsl:if>
                     </frbrizer:relationship>
                  </xsl:if>
               </xsl:for-each>
            </xsl:for-each>
         </xsl:element>
      </xsl:for-each>
   </xsl:template>
   <xsl:template name="MARC21-700-Related-Work">
      <xsl:variable name="this_template_name" select="'MARC21-700-Related-Work'"/>
      <xsl:variable name="tag" as="xs:string" select="'700, 710, 711, 730'"/>
      <xsl:variable name="code" as="xs:string" select="'4'"/>
      <xsl:variable name="record" select="."/>
      <xsl:variable name="marcid" select="*:controlfield[@tag='001']"/>
      <xsl:for-each select="node()[@tag=('700','710','711','730')][exists(*:subfield[@code = '1' and starts-with(., 'http')]) and not(@ind2 = '2') and (if (@tag eq '730') then true() else *:subfield/@code = 't')]">
         <xsl:variable name="this_field"
                        select="(ancestor-or-self::*:datafield, ancestor-or-self::*:controlfield)"/>
         <xsl:variable name="this"
                        select="(ancestor-or-self::*:datafield, ancestor-or-self::*:controlfield)"/>
         <xsl:variable name="anchor_field"
                        select="(ancestor-or-self::*:datafield, ancestor-or-self::*:controlfield)"/>
         <xsl:variable name="anchor"
                        as="xs:string"
                        select="(ancestor-or-self::*:datafield, ancestor-or-self::*:controlfield)"/>
         <xsl:variable name="this_field_position"
                        as="xs:string"
                        select="string(position())"/>
         <xsl:for-each select="node()[@code=('4')][starts-with(., 'http')]">
            <xsl:variable name="this_subfield" select="(ancestor-or-self::*:subfield)"/>
            <xsl:variable name="anchor_subfield" select="(ancestor-or-self::*:subfield)"/>
            <xsl:variable name="this_subfield_code"
                           as="xs:string"
                           select="$this_subfield/@code"/>
            <xsl:variable name="anchor_subfield_code"
                           as="xs:string"
                           select="$this_subfield/@code"/>
            <xsl:variable name="this_subfield_position"
                           as="xs:string"
                           select="string(position())"/>
            <xsl:element name="{name(ancestor-or-self::*:record)}"
                          namespace="{namespace-uri(ancestor-or-self::*:record)}">
               <xsl:attribute name="id"
                               select="string-join(($record/@id,$this_template_name,$tag,$this_subfield_code,$this_field_position,$this_subfield_position), ':')"/>
               <xsl:attribute name="type" select="'http://rdaregistry.info/Elements/c/C10001'"/>
               <xsl:attribute name="templatename" select="$this_template_name"/>
               <xsl:for-each select="$record/*:datafield[@tag='700'][. eq $this_field][*:subfield/@code = ('t','f','n','1')]">
                  <xsl:copy>
                     <xsl:call-template name="copy-attributes"/>
                     <xsl:for-each select="*:subfield[@code = ('t','f','n','1')]">
                        <xsl:if test="@code = 't'">
                           <xsl:copy>
                              <xsl:call-template name="copy-content">
                                 <xsl:with-param name="type" select="'http://www.w3.org/2000/01/rdf-schema#label'"/>
                                 <xsl:with-param name="select"
                                                  select="frbrizer:trim(.) || ' (' || ../*:subfield[@code='a']/replace(., '[\s,/:=]+$', '') || ')'"/>
                              </xsl:call-template>
                           </xsl:copy>
                        </xsl:if>
                        <xsl:if test="@code = 't'">
                           <xsl:copy>
                              <xsl:call-template name="copy-content">
                                 <xsl:with-param name="type"
                                                  select="'http://rdaregistry.info/Elements/w/datatype/P10088'"/>
                                 <xsl:with-param name="select"
                                                  select="string-join((frbrizer:trim(.), frbrizer:trim(../*:subfield[@code = 'p'])), ' : ')"/>
                              </xsl:call-template>
                           </xsl:copy>
                        </xsl:if>
                        <xsl:if test="@code = 'f'">
                           <xsl:copy>
                              <xsl:call-template name="copy-content">
                                 <xsl:with-param name="type"
                                                  select="'http://rdaregistry.info/Elements/w/datatype/P10219'"/>
                                 <xsl:with-param name="select" select="."/>
                              </xsl:call-template>
                           </xsl:copy>
                        </xsl:if>
                        <xsl:if test="@code = 'n'">
                           <xsl:copy>
                              <xsl:call-template name="copy-content">
                                 <xsl:with-param name="type"
                                                  select="'http://rdaregistry.info/Elements/w/datatype/P10012'"/>
                                 <xsl:with-param name="select" select="."/>
                              </xsl:call-template>
                           </xsl:copy>
                        </xsl:if>
                        <xsl:if test="@code = '1'">
                           <xsl:copy>
                              <xsl:call-template name="copy-content">
                                 <xsl:with-param name="type"
                                                  select="'http://rdaregistry.info/Elements/x/datatype/P00018'"/>
                                 <xsl:with-param name="select" select="."/>
                              </xsl:call-template>
                           </xsl:copy>
                        </xsl:if>
                     </xsl:for-each>
                  </xsl:copy>
               </xsl:for-each>
               <xsl:for-each select="$record/*:datafield[@tag='710'][. eq $this_field][*:subfield/@code = ('t','f','n','1')]">
                  <xsl:copy>
                     <xsl:call-template name="copy-attributes"/>
                     <xsl:for-each select="*:subfield[@code = ('t','f','n','1')]">
                        <xsl:if test="@code = 't'">
                           <xsl:copy>
                              <xsl:call-template name="copy-content">
                                 <xsl:with-param name="type" select="'http://www.w3.org/2000/01/rdf-schema#label'"/>
                                 <xsl:with-param name="select" select="frbrizer:trim(.)"/>
                              </xsl:call-template>
                           </xsl:copy>
                        </xsl:if>
                        <xsl:if test="@code = 't'">
                           <xsl:copy>
                              <xsl:call-template name="copy-content">
                                 <xsl:with-param name="type"
                                                  select="'http://rdaregistry.info/Elements/w/datatype/P10088'"/>
                                 <xsl:with-param name="select"
                                                  select="string-join((frbrizer:trim(.), frbrizer:trim(../*:subfield[@code = 'p'])), ' : ')"/>
                              </xsl:call-template>
                           </xsl:copy>
                        </xsl:if>
                        <xsl:if test="@code = 'f'">
                           <xsl:copy>
                              <xsl:call-template name="copy-content">
                                 <xsl:with-param name="type"
                                                  select="'http://rdaregistry.info/Elements/w/datatype/P10219'"/>
                                 <xsl:with-param name="select" select="."/>
                              </xsl:call-template>
                           </xsl:copy>
                        </xsl:if>
                        <xsl:if test="@code = 'n'">
                           <xsl:copy>
                              <xsl:call-template name="copy-content">
                                 <xsl:with-param name="type"
                                                  select="'http://rdaregistry.info/Elements/w/datatype/P10012'"/>
                                 <xsl:with-param name="select" select="."/>
                              </xsl:call-template>
                           </xsl:copy>
                        </xsl:if>
                        <xsl:if test="@code = '1'">
                           <xsl:copy>
                              <xsl:call-template name="copy-content">
                                 <xsl:with-param name="type"
                                                  select="'http://rdaregistry.info/Elements/x/datatype/P00018'"/>
                                 <xsl:with-param name="select" select="."/>
                              </xsl:call-template>
                           </xsl:copy>
                        </xsl:if>
                     </xsl:for-each>
                  </xsl:copy>
               </xsl:for-each>
               <xsl:for-each select="$record/*:datafield[@tag='711'][. eq $this_field][*:subfield/@code = ('t','f','n','1')]">
                  <xsl:copy>
                     <xsl:call-template name="copy-attributes"/>
                     <xsl:for-each select="*:subfield[@code = ('t','f','n','1')]">
                        <xsl:if test="@code = 't'">
                           <xsl:copy>
                              <xsl:call-template name="copy-content">
                                 <xsl:with-param name="type" select="'http://www.w3.org/2000/01/rdf-schema#label'"/>
                                 <xsl:with-param name="select" select="frbrizer:trim(.)"/>
                              </xsl:call-template>
                           </xsl:copy>
                        </xsl:if>
                        <xsl:if test="@code = 't'">
                           <xsl:copy>
                              <xsl:call-template name="copy-content">
                                 <xsl:with-param name="type"
                                                  select="'http://rdaregistry.info/Elements/w/datatype/P10088'"/>
                                 <xsl:with-param name="select"
                                                  select="string-join((frbrizer:trim(.), frbrizer:trim(../*:subfield[@code = 'p'])), ' : ')"/>
                              </xsl:call-template>
                           </xsl:copy>
                        </xsl:if>
                        <xsl:if test="@code = 'f'">
                           <xsl:copy>
                              <xsl:call-template name="copy-content">
                                 <xsl:with-param name="type"
                                                  select="'http://rdaregistry.info/Elements/w/datatype/P10219'"/>
                                 <xsl:with-param name="select" select="."/>
                              </xsl:call-template>
                           </xsl:copy>
                        </xsl:if>
                        <xsl:if test="@code = 'n'">
                           <xsl:copy>
                              <xsl:call-template name="copy-content">
                                 <xsl:with-param name="type"
                                                  select="'http://rdaregistry.info/Elements/w/datatype/P10012'"/>
                                 <xsl:with-param name="select" select="."/>
                              </xsl:call-template>
                           </xsl:copy>
                        </xsl:if>
                        <xsl:if test="@code = '1'">
                           <xsl:copy>
                              <xsl:call-template name="copy-content">
                                 <xsl:with-param name="type"
                                                  select="'http://rdaregistry.info/Elements/x/datatype/P00018'"/>
                                 <xsl:with-param name="select" select="."/>
                              </xsl:call-template>
                           </xsl:copy>
                        </xsl:if>
                     </xsl:for-each>
                  </xsl:copy>
               </xsl:for-each>
               <xsl:for-each select="$record/*:datafield[@tag='730'][. eq $this_field][*:subfield/@code = ('a','f','n','1')]">
                  <xsl:copy>
                     <xsl:call-template name="copy-attributes"/>
                     <xsl:for-each select="*:subfield[@code = ('a','f','n','1')]">
                        <xsl:if test="@code = 'a'">
                           <xsl:copy>
                              <xsl:call-template name="copy-content">
                                 <xsl:with-param name="type" select="'http://www.w3.org/2000/01/rdf-schema#label'"/>
                                 <xsl:with-param name="select" select="frbrizer:trim(.)"/>
                              </xsl:call-template>
                           </xsl:copy>
                        </xsl:if>
                        <xsl:if test="@code = 'a'">
                           <xsl:copy>
                              <xsl:call-template name="copy-content">
                                 <xsl:with-param name="type"
                                                  select="'http://rdaregistry.info/Elements/w/datatype/P10088'"/>
                                 <xsl:with-param name="select"
                                                  select="string-join((frbrizer:trim(.), frbrizer:trim(../*:subfield[@code = 'p'])), ' : ')"/>
                              </xsl:call-template>
                           </xsl:copy>
                        </xsl:if>
                        <xsl:if test="@code = 'f'">
                           <xsl:copy>
                              <xsl:call-template name="copy-content">
                                 <xsl:with-param name="type"
                                                  select="'http://rdaregistry.info/Elements/w/datatype/P10219'"/>
                                 <xsl:with-param name="select" select="."/>
                              </xsl:call-template>
                           </xsl:copy>
                        </xsl:if>
                        <xsl:if test="@code = 'n'">
                           <xsl:copy>
                              <xsl:call-template name="copy-content">
                                 <xsl:with-param name="type"
                                                  select="'http://rdaregistry.info/Elements/w/datatype/P10012'"/>
                                 <xsl:with-param name="select" select="."/>
                              </xsl:call-template>
                           </xsl:copy>
                        </xsl:if>
                        <xsl:if test="@code = '1'">
                           <xsl:copy>
                              <xsl:call-template name="copy-content">
                                 <xsl:with-param name="type"
                                                  select="'http://rdaregistry.info/Elements/x/datatype/P00018'"/>
                                 <xsl:with-param name="select" select="."/>
                              </xsl:call-template>
                           </xsl:copy>
                        </xsl:if>
                     </xsl:for-each>
                  </xsl:copy>
               </xsl:for-each>
            </xsl:element>
         </xsl:for-each>
      </xsl:for-each>
   </xsl:template>
   <xsl:template name="MARC21-700-Work-Analytical">
      <xsl:variable name="this_template_name" select="'MARC21-700-Work-Analytical'"/>
      <xsl:variable name="tag" as="xs:string" select="'700, 710, 711, 730'"/>
      <xsl:variable name="record" select="."/>
      <xsl:variable name="marcid" select="*:controlfield[@tag='001']"/>
      <xsl:for-each select="node()[@tag=('700','710','711','730')][exists(*:subfield[@code = '1']/starts-with(., 'http'))  and @ind2='2' and (if (@tag eq '730') then true() else *:subfield/@code = 't')]">
         <xsl:variable name="this_field"
                        select="(ancestor-or-self::*:datafield, ancestor-or-self::*:controlfield)"/>
         <xsl:variable name="this"
                        select="(ancestor-or-self::*:datafield, ancestor-or-self::*:controlfield)"/>
         <xsl:variable name="anchor_field"
                        select="(ancestor-or-self::*:datafield, ancestor-or-self::*:controlfield)"/>
         <xsl:variable name="anchor"
                        as="xs:string"
                        select="(ancestor-or-self::*:datafield, ancestor-or-self::*:controlfield)"/>
         <xsl:variable name="this_field_position"
                        as="xs:string"
                        select="string(position())"/>
         <xsl:element name="{name(ancestor-or-self::*:record)}"
                       namespace="{namespace-uri(ancestor-or-self::*:record)}">
            <xsl:attribute name="id"
                            select="string-join(($record/@id,$this_template_name,$tag,$this_field_position), ':')"/>
            <xsl:attribute name="type" select="'http://rdaregistry.info/Elements/c/C10001'"/>
            <xsl:attribute name="templatename" select="$this_template_name"/>
            <xsl:for-each select="$record/*:datafield[@tag='700'][. eq $this_field][*:subfield/@code = ('t','f','n','1')]">
               <xsl:copy>
                  <xsl:call-template name="copy-attributes"/>
                  <xsl:for-each select="*:subfield[@code = ('t','f','n','1')]">
                     <xsl:if test="@code = 't'">
                        <xsl:copy>
                           <xsl:call-template name="copy-content">
                              <xsl:with-param name="type" select="'http://www.w3.org/2000/01/rdf-schema#label'"/>
                              <xsl:with-param name="select"
                                               select="frbrizer:trim(.) || ' (' || ../*:subfield[@code='a']/replace(., '[\s,/:=]+$', '') || ')'"/>
                           </xsl:call-template>
                        </xsl:copy>
                     </xsl:if>
                     <xsl:if test="@code = 't'">
                        <xsl:copy>
                           <xsl:call-template name="copy-content">
                              <xsl:with-param name="type"
                                               select="'http://rdaregistry.info/Elements/w/datatype/P10088'"/>
                              <xsl:with-param name="select"
                                               select="string-join((frbrizer:trim(.), frbrizer:trim(../*:subfield[@code = 'p'])), ' : ')"/>
                           </xsl:call-template>
                        </xsl:copy>
                     </xsl:if>
                     <xsl:if test="@code = 'f'">
                        <xsl:copy>
                           <xsl:call-template name="copy-content">
                              <xsl:with-param name="type"
                                               select="'http://rdaregistry.info/Elements/w/datatype/P10219'"/>
                              <xsl:with-param name="select" select="."/>
                           </xsl:call-template>
                        </xsl:copy>
                     </xsl:if>
                     <xsl:if test="@code = 'n'">
                        <xsl:copy>
                           <xsl:call-template name="copy-content">
                              <xsl:with-param name="type"
                                               select="'http://rdaregistry.info/Elements/w/datatype/P10012'"/>
                              <xsl:with-param name="select" select="."/>
                           </xsl:call-template>
                        </xsl:copy>
                     </xsl:if>
                     <xsl:if test="@code = '1'">
                        <xsl:copy>
                           <xsl:call-template name="copy-content">
                              <xsl:with-param name="type"
                                               select="'http://rdaregistry.info/Elements/x/datatype/P00018'"/>
                              <xsl:with-param name="select" select="."/>
                           </xsl:call-template>
                        </xsl:copy>
                     </xsl:if>
                  </xsl:for-each>
               </xsl:copy>
            </xsl:for-each>
            <xsl:for-each select="$record/*:datafield[@tag='710'][. eq $this_field][*:subfield/@code = ('t','f','n','1')]">
               <xsl:copy>
                  <xsl:call-template name="copy-attributes"/>
                  <xsl:for-each select="*:subfield[@code = ('t','f','n','1')]">
                     <xsl:if test="@code = 't'">
                        <xsl:copy>
                           <xsl:call-template name="copy-content">
                              <xsl:with-param name="type" select="'http://www.w3.org/2000/01/rdf-schema#label'"/>
                              <xsl:with-param name="select" select="frbrizer:trim(.)"/>
                           </xsl:call-template>
                        </xsl:copy>
                     </xsl:if>
                     <xsl:if test="@code = 't'">
                        <xsl:copy>
                           <xsl:call-template name="copy-content">
                              <xsl:with-param name="type"
                                               select="'http://rdaregistry.info/Elements/w/datatype/P10088'"/>
                              <xsl:with-param name="select"
                                               select="string-join((frbrizer:trim(.), frbrizer:trim(../*:subfield[@code = 'p'])), ' : ')"/>
                           </xsl:call-template>
                        </xsl:copy>
                     </xsl:if>
                     <xsl:if test="@code = 'f'">
                        <xsl:copy>
                           <xsl:call-template name="copy-content">
                              <xsl:with-param name="type"
                                               select="'http://rdaregistry.info/Elements/w/datatype/P10219'"/>
                              <xsl:with-param name="select" select="."/>
                           </xsl:call-template>
                        </xsl:copy>
                     </xsl:if>
                     <xsl:if test="@code = 'n'">
                        <xsl:copy>
                           <xsl:call-template name="copy-content">
                              <xsl:with-param name="type"
                                               select="'http://rdaregistry.info/Elements/w/datatype/P10012'"/>
                              <xsl:with-param name="select" select="."/>
                           </xsl:call-template>
                        </xsl:copy>
                     </xsl:if>
                     <xsl:if test="@code = '1'">
                        <xsl:copy>
                           <xsl:call-template name="copy-content">
                              <xsl:with-param name="type"
                                               select="'http://rdaregistry.info/Elements/x/datatype/P00018'"/>
                              <xsl:with-param name="select" select="."/>
                           </xsl:call-template>
                        </xsl:copy>
                     </xsl:if>
                  </xsl:for-each>
               </xsl:copy>
            </xsl:for-each>
            <xsl:for-each select="$record/*:datafield[@tag='711'][. eq $this_field][*:subfield/@code = ('t','f','n','1')]">
               <xsl:copy>
                  <xsl:call-template name="copy-attributes"/>
                  <xsl:for-each select="*:subfield[@code = ('t','f','n','1')]">
                     <xsl:if test="@code = 't'">
                        <xsl:copy>
                           <xsl:call-template name="copy-content">
                              <xsl:with-param name="type" select="'http://www.w3.org/2000/01/rdf-schema#label'"/>
                              <xsl:with-param name="select" select="frbrizer:trim(.)"/>
                           </xsl:call-template>
                        </xsl:copy>
                     </xsl:if>
                     <xsl:if test="@code = 't'">
                        <xsl:copy>
                           <xsl:call-template name="copy-content">
                              <xsl:with-param name="type"
                                               select="'http://rdaregistry.info/Elements/w/datatype/P10088'"/>
                              <xsl:with-param name="select"
                                               select="string-join((frbrizer:trim(.), frbrizer:trim(../*:subfield[@code = 'p'])), ' : ')"/>
                           </xsl:call-template>
                        </xsl:copy>
                     </xsl:if>
                     <xsl:if test="@code = 'f'">
                        <xsl:copy>
                           <xsl:call-template name="copy-content">
                              <xsl:with-param name="type"
                                               select="'http://rdaregistry.info/Elements/w/datatype/P10219'"/>
                              <xsl:with-param name="select" select="."/>
                           </xsl:call-template>
                        </xsl:copy>
                     </xsl:if>
                     <xsl:if test="@code = 'n'">
                        <xsl:copy>
                           <xsl:call-template name="copy-content">
                              <xsl:with-param name="type"
                                               select="'http://rdaregistry.info/Elements/w/datatype/P10012'"/>
                              <xsl:with-param name="select" select="."/>
                           </xsl:call-template>
                        </xsl:copy>
                     </xsl:if>
                     <xsl:if test="@code = '1'">
                        <xsl:copy>
                           <xsl:call-template name="copy-content">
                              <xsl:with-param name="type"
                                               select="'http://rdaregistry.info/Elements/x/datatype/P00018'"/>
                              <xsl:with-param name="select" select="."/>
                           </xsl:call-template>
                        </xsl:copy>
                     </xsl:if>
                  </xsl:for-each>
               </xsl:copy>
            </xsl:for-each>
            <xsl:for-each select="$record/*:datafield[@tag='730'][. eq $this_field][*:subfield/@code = ('a','f','n','1')]">
               <xsl:copy>
                  <xsl:call-template name="copy-attributes"/>
                  <xsl:for-each select="*:subfield[@code = ('a','f','n','1')]">
                     <xsl:if test="@code = 'a'">
                        <xsl:copy>
                           <xsl:call-template name="copy-content">
                              <xsl:with-param name="type" select="'http://www.w3.org/2000/01/rdf-schema#label'"/>
                              <xsl:with-param name="select" select="frbrizer:trim(.)"/>
                           </xsl:call-template>
                        </xsl:copy>
                     </xsl:if>
                     <xsl:if test="@code = 'a'">
                        <xsl:copy>
                           <xsl:call-template name="copy-content">
                              <xsl:with-param name="type"
                                               select="'http://rdaregistry.info/Elements/w/datatype/P10088'"/>
                              <xsl:with-param name="select"
                                               select="string-join((frbrizer:trim(.), frbrizer:trim(../*:subfield[@code = 'p'])), ' : ')"/>
                           </xsl:call-template>
                        </xsl:copy>
                     </xsl:if>
                     <xsl:if test="@code = 'f'">
                        <xsl:copy>
                           <xsl:call-template name="copy-content">
                              <xsl:with-param name="type"
                                               select="'http://rdaregistry.info/Elements/w/datatype/P10219'"/>
                              <xsl:with-param name="select" select="."/>
                           </xsl:call-template>
                        </xsl:copy>
                     </xsl:if>
                     <xsl:if test="@code = 'n'">
                        <xsl:copy>
                           <xsl:call-template name="copy-content">
                              <xsl:with-param name="type"
                                               select="'http://rdaregistry.info/Elements/w/datatype/P10012'"/>
                              <xsl:with-param name="select" select="."/>
                           </xsl:call-template>
                        </xsl:copy>
                     </xsl:if>
                     <xsl:if test="@code = '1'">
                        <xsl:copy>
                           <xsl:call-template name="copy-content">
                              <xsl:with-param name="type"
                                               select="'http://rdaregistry.info/Elements/x/datatype/P00018'"/>
                              <xsl:with-param name="select" select="."/>
                           </xsl:call-template>
                        </xsl:copy>
                     </xsl:if>
                  </xsl:for-each>
               </xsl:copy>
            </xsl:for-each>
            <xsl:for-each select="$record/node()[@tag=('130','240')][*:subfield/@code = '1']">
               <xsl:variable name="target_template_name" select="'MARC21-130240-Work'"/>
               <xsl:variable name="target_tag_value" select="'130, 240'"/>
               <xsl:variable name="target_field"
                              select="(ancestor-or-self::*:datafield, ancestor-or-self::*:controlfield)"/>
               <xsl:variable name="target_field_position"
                              as="xs:string"
                              select="string(position())"/>
               <xsl:for-each select="node()[@code=('1')][starts-with(., 'http')]">
                  <xsl:variable name="target_subfield" select="."/>
                  <xsl:variable name="target_subfield_code"
                                 as="xs:string"
                                 select="$target_subfield/@code"/>
                  <xsl:variable name="target_subfield_position"
                                 as="xs:string"
                                 select="string(position())"/>
                  <frbrizer:relationship>
                     <xsl:attribute name="type" select="'http://rdaregistry.info/Elements/w/object/P10019'"/>
                     <xsl:attribute name="href"
                                     select="string-join(($record/@id,$target_template_name,$target_tag_value,$target_subfield_code,$target_field_position,$target_subfield_position), ':')"/>
                     <xsl:if test="$include_internal_key">
                        <xsl:attribute name="intkey"
                                        select="string-join(($record/@id,$target_template_name,$target_tag_value,$target_subfield_code,$target_field_position,$target_subfield_position), ':')"/>
                     </xsl:if>
                  </frbrizer:relationship>
               </xsl:for-each>
            </xsl:for-each>
            <xsl:for-each select="$record/node()[@tag=('600','610','611')][exists(*:subfield[@code = '1']/starts-with(., 'http')) and not(*:subfield/@code = 't')]">
               <xsl:variable name="target_template_name" select="'MARC21-600-Person'"/>
               <xsl:variable name="target_tag_value" select="'600, 610, 611'"/>
               <xsl:variable name="target_field"
                              select="(ancestor-or-self::*:datafield, ancestor-or-self::*:controlfield)"/>
               <xsl:variable name="target_field_position"
                              as="xs:string"
                              select="string(position())"/>
               <xsl:if test="(frbrizer:linked($anchor_field, $target_field, false()))">
                  <frbrizer:relationship>
                     <xsl:attribute name="type" select="'http://rdaregistry.info/Elements/w/object/P10319'"/>
                     <xsl:attribute name="href"
                                     select="string-join(($record/@id,$target_template_name,$target_tag_value,$target_field_position), ':')"/>
                     <xsl:if test="$include_internal_key">
                        <xsl:attribute name="intkey"
                                        select="string-join(($record/@id,$target_template_name,$target_tag_value,$target_field_position), ':')"/>
                     </xsl:if>
                  </frbrizer:relationship>
               </xsl:if>
            </xsl:for-each>
            <xsl:for-each select="$record/node()[@tag=('600','610','611','630')][*:subfield/@code = '1' and  (if (@tag eq '630') then true() else *:subfield/@code = 't')]">
               <xsl:variable name="target_template_name" select="'MARC21-6XX-Work'"/>
               <xsl:variable name="target_tag_value" select="'600, 610, 611, 630'"/>
               <xsl:variable name="target_field"
                              select="(ancestor-or-self::*:datafield, ancestor-or-self::*:controlfield)"/>
               <xsl:variable name="target_field_position"
                              as="xs:string"
                              select="string(position())"/>
               <xsl:for-each select="node()[@code=('1')][starts-with(., 'http')]">
                  <xsl:variable name="target_subfield" select="."/>
                  <xsl:variable name="target_subfield_code"
                                 as="xs:string"
                                 select="$target_subfield/@code"/>
                  <xsl:variable name="target_subfield_position"
                                 as="xs:string"
                                 select="string(position())"/>
                  <xsl:if test="(frbrizer:linked($anchor_field, $target_field, false()) and not($this_field/*:subfield[@code = '1'] = $target_field/*:subfield[@code = '1']))">
                     <frbrizer:relationship>
                        <xsl:attribute name="type" select="'http://rdaregistry.info/Elements/w/object/P10257'"/>
                        <xsl:attribute name="href"
                                        select="string-join(($record/@id,$target_template_name,$target_tag_value,$target_subfield_code,$target_field_position,$target_subfield_position), ':')"/>
                        <xsl:if test="$include_internal_key">
                           <xsl:attribute name="intkey"
                                           select="string-join(($record/@id,$target_template_name,$target_tag_value,$target_subfield_code,$target_field_position,$target_subfield_position), ':')"/>
                        </xsl:if>
                     </frbrizer:relationship>
                  </xsl:if>
               </xsl:for-each>
            </xsl:for-each>
            <xsl:for-each select="$record/node()[@tag=('100','110','111','700','710','711')][exists(*:subfield[@code = '1']/starts-with(., 'http')) and not(*:subfield/@code = 't')]">
               <xsl:variable name="target_template_name" select="'MARC21-100700Person'"/>
               <xsl:variable name="target_tag_value" select="'100, 110, 111, 700, 710, 711'"/>
               <xsl:variable name="target_field"
                              select="(ancestor-or-self::*:datafield, ancestor-or-self::*:controlfield)"/>
               <xsl:variable name="target_field_position"
                              as="xs:string"
                              select="string(position())"/>
               <xsl:for-each select="node()[@code=('4')][starts-with(., 'http')]">
                  <xsl:variable name="target_subfield" select="."/>
                  <xsl:variable name="target_subfield_code"
                                 as="xs:string"
                                 select="$target_subfield/@code"/>
                  <xsl:variable name="target_subfield_position"
                                 as="xs:string"
                                 select="string(position())"/>
                  <xsl:if test="(starts-with($target_subfield, 'http://rdaregistry.info/Elements/w/') and frbrizer:linked($anchor_field, $target_field, false()))">
                     <frbrizer:relationship>
                        <xsl:attribute name="type" select="$target_subfield"/>
                        <xsl:attribute name="href"
                                        select="string-join(($record/@id,$target_template_name,$target_tag_value,$target_subfield_code,$target_field_position,$target_subfield_position), ':')"/>
                        <xsl:if test="$include_internal_key">
                           <xsl:attribute name="intkey"
                                           select="string-join(($record/@id,$target_template_name,$target_tag_value,$target_subfield_code,$target_field_position,$target_subfield_position), ':')"/>
                        </xsl:if>
                     </frbrizer:relationship>
                  </xsl:if>
               </xsl:for-each>
            </xsl:for-each>
            <xsl:for-each select="$record/node()[@tag=('700','710','711','730')][exists(*:subfield[@code = '1' and starts-with(., 'http')]) and not(@ind2 = '2') and (if (@tag eq '730') then true() else *:subfield/@code = 't')]">
               <xsl:variable name="target_template_name" select="'MARC21-700-Related-Work'"/>
               <xsl:variable name="target_tag_value" select="'700, 710, 711, 730'"/>
               <xsl:variable name="target_field"
                              select="(ancestor-or-self::*:datafield, ancestor-or-self::*:controlfield)"/>
               <xsl:variable name="target_field_position"
                              as="xs:string"
                              select="string(position())"/>
               <xsl:for-each select="node()[@code=('4')][starts-with(., 'http')]">
                  <xsl:variable name="target_subfield" select="."/>
                  <xsl:variable name="target_subfield_code"
                                 as="xs:string"
                                 select="$target_subfield/@code"/>
                  <xsl:variable name="target_subfield_position"
                                 as="xs:string"
                                 select="string(position())"/>
                  <xsl:if test="(starts-with($target_subfield, 'http://rdaregistry.info/Elements/w/') and frbrizer:linked($anchor_field, $target_field, false()))">
                     <frbrizer:relationship>
                        <xsl:attribute name="type" select="$target_subfield"/>
                        <xsl:attribute name="href"
                                        select="string-join(($record/@id,$target_template_name,$target_tag_value,$target_subfield_code,$target_field_position,$target_subfield_position), ':')"/>
                        <xsl:if test="$include_internal_key">
                           <xsl:attribute name="intkey"
                                           select="string-join(($record/@id,$target_template_name,$target_tag_value,$target_subfield_code,$target_field_position,$target_subfield_position), ':')"/>
                        </xsl:if>
                     </frbrizer:relationship>
                  </xsl:if>
               </xsl:for-each>
            </xsl:for-each>
            <xsl:for-each select="$record/node()[@tag=('758')]">
               <xsl:variable name="target_template_name" select="'MARC21-758-Related-Work'"/>
               <xsl:variable name="target_tag_value" select="'758'"/>
               <xsl:variable name="target_field"
                              select="(ancestor-or-self::*:datafield, ancestor-or-self::*:controlfield)"/>
               <xsl:variable name="target_field_position"
                              as="xs:string"
                              select="string(position())"/>
               <xsl:for-each select="node()[@code=('4')][starts-with(., 'http') and exists($this_field/*:subfield[@code = '1']/starts-with(., 'http')) ]">
                  <xsl:variable name="target_subfield" select="."/>
                  <xsl:variable name="target_subfield_code"
                                 as="xs:string"
                                 select="$target_subfield/@code"/>
                  <xsl:variable name="target_subfield_position"
                                 as="xs:string"
                                 select="string(position())"/>
                  <xsl:if test="(starts-with($target_subfield, 'http://rdaregistry.info/Elements/w/')  and frbrizer:linked($anchor_field, $target_field, false()))">
                     <frbrizer:relationship>
                        <xsl:attribute name="type" select="$target_subfield"/>
                        <xsl:attribute name="href"
                                        select="string-join(($record/@id,$target_template_name,$target_tag_value,$target_subfield_code,$target_field_position,$target_subfield_position), ':')"/>
                        <xsl:if test="$include_internal_key">
                           <xsl:attribute name="intkey"
                                           select="string-join(($record/@id,$target_template_name,$target_tag_value,$target_subfield_code,$target_field_position,$target_subfield_position), ':')"/>
                        </xsl:if>
                     </frbrizer:relationship>
                  </xsl:if>
               </xsl:for-each>
            </xsl:for-each>
            <xsl:for-each select="$record/node()[@tag=('380')]">
               <xsl:variable name="target_template_name" select="'MARC380'"/>
               <xsl:variable name="target_tag_value" select="'380'"/>
               <xsl:variable name="target_field"
                              select="(ancestor-or-self::*:datafield, ancestor-or-self::*:controlfield)"/>
               <xsl:variable name="target_field_position"
                              as="xs:string"
                              select="string(position())"/>
               <xsl:for-each select="node()[@code=('0')][starts-with(., 'http')]">
                  <xsl:variable name="target_subfield" select="."/>
                  <xsl:variable name="target_subfield_code"
                                 as="xs:string"
                                 select="$target_subfield/@code"/>
                  <xsl:variable name="target_subfield_position"
                                 as="xs:string"
                                 select="string(position())"/>
                  <xsl:if test="(frbrizer:linked($anchor_field, $target_field, false()))">
                     <frbrizer:relationship>
                        <xsl:attribute name="type"
                                        select="'http://rdaregistry.info/Elements/w/datatype/P10004'"/>
                        <xsl:attribute name="href"
                                        select="string-join(($record/@id,$target_template_name,$target_tag_value,$target_subfield_code,$target_field_position,$target_subfield_position), ':')"/>
                        <xsl:if test="$include_internal_key">
                           <xsl:attribute name="intkey"
                                           select="string-join(($record/@id,$target_template_name,$target_tag_value,$target_subfield_code,$target_field_position,$target_subfield_position), ':')"/>
                        </xsl:if>
                     </frbrizer:relationship>
                  </xsl:if>
               </xsl:for-each>
            </xsl:for-each>
         </xsl:element>
      </xsl:for-each>
   </xsl:template>
   <xsl:template name="MARC21-758-Related-Work">
      <xsl:variable name="this_template_name" select="'MARC21-758-Related-Work'"/>
      <xsl:variable name="tag" as="xs:string" select="'758'"/>
      <xsl:variable name="code" as="xs:string" select="'4'"/>
      <xsl:variable name="record" select="."/>
      <xsl:variable name="marcid" select="*:controlfield[@tag='001']"/>
      <xsl:for-each select="node()[@tag=('758')]">
         <xsl:variable name="this_field"
                        select="(ancestor-or-self::*:datafield, ancestor-or-self::*:controlfield)"/>
         <xsl:variable name="this"
                        select="(ancestor-or-self::*:datafield, ancestor-or-self::*:controlfield)"/>
         <xsl:variable name="anchor_field"
                        select="(ancestor-or-self::*:datafield, ancestor-or-self::*:controlfield)"/>
         <xsl:variable name="anchor"
                        as="xs:string"
                        select="(ancestor-or-self::*:datafield, ancestor-or-self::*:controlfield)"/>
         <xsl:variable name="this_field_position"
                        as="xs:string"
                        select="string(position())"/>
         <xsl:for-each select="node()[@code=('4')][starts-with(., 'http') and exists($this_field/*:subfield[@code = '1']/starts-with(., 'http')) ]">
            <xsl:variable name="this_subfield" select="(ancestor-or-self::*:subfield)"/>
            <xsl:variable name="anchor_subfield" select="(ancestor-or-self::*:subfield)"/>
            <xsl:variable name="this_subfield_code"
                           as="xs:string"
                           select="$this_subfield/@code"/>
            <xsl:variable name="anchor_subfield_code"
                           as="xs:string"
                           select="$this_subfield/@code"/>
            <xsl:variable name="this_subfield_position"
                           as="xs:string"
                           select="string(position())"/>
            <xsl:element name="{name(ancestor-or-self::*:record)}"
                          namespace="{namespace-uri(ancestor-or-self::*:record)}">
               <xsl:attribute name="id"
                               select="string-join(($record/@id,$this_template_name,$tag,$this_subfield_code,$this_field_position,$this_subfield_position), ':')"/>
               <xsl:attribute name="type" select="'http://rdaregistry.info/Elements/c/C10001'"/>
               <xsl:attribute name="templatename" select="$this_template_name"/>
               <xsl:for-each select="$record/*:datafield[@tag='758'][. = $this_field][*:subfield/@code = ('a','1')]">
                  <xsl:copy>
                     <xsl:call-template name="copy-attributes"/>
                     <xsl:for-each select="*:subfield[@code = ('a','1')]">
                        <xsl:if test="@code = 'a'">
                           <xsl:copy>
                              <xsl:call-template name="copy-content">
                                 <xsl:with-param name="type" select="'http://www.w3.org/2000/01/rdf-schema#label'"/>
                                 <xsl:with-param name="select" select="frbrizer:trim(.)"/>
                              </xsl:call-template>
                           </xsl:copy>
                        </xsl:if>
                        <xsl:if test="@code = '1'">
                           <xsl:copy>
                              <xsl:call-template name="copy-content">
                                 <xsl:with-param name="type"
                                                  select="'http://rdaregistry.info/Elements/x/datatype/P00018'"/>
                                 <xsl:with-param name="select" select="."/>
                              </xsl:call-template>
                           </xsl:copy>
                        </xsl:if>
                     </xsl:for-each>
                  </xsl:copy>
               </xsl:for-each>
            </xsl:element>
         </xsl:for-each>
      </xsl:for-each>
   </xsl:template>
   <xsl:template name="MARC21-8XX-Work-Series">
      <xsl:variable name="this_template_name" select="'MARC21-8XX-Work-Series'"/>
      <xsl:variable name="tag" as="xs:string" select="'800, 810, 811, 830'"/>
      <xsl:variable name="code" as="xs:string" select="'1'"/>
      <xsl:variable name="record" select="."/>
      <xsl:variable name="marcid" select="*:controlfield[@tag='001']"/>
      <xsl:for-each select="node()[@tag=('800','810','811','830')]">
         <xsl:variable name="this_field"
                        select="(ancestor-or-self::*:datafield, ancestor-or-self::*:controlfield)"/>
         <xsl:variable name="this"
                        select="(ancestor-or-self::*:datafield, ancestor-or-self::*:controlfield)"/>
         <xsl:variable name="anchor_field"
                        select="(ancestor-or-self::*:datafield, ancestor-or-self::*:controlfield)"/>
         <xsl:variable name="anchor"
                        as="xs:string"
                        select="(ancestor-or-self::*:datafield, ancestor-or-self::*:controlfield)"/>
         <xsl:variable name="this_field_position"
                        as="xs:string"
                        select="string(position())"/>
         <xsl:for-each select="node()[@code=('1')][starts-with(., 'http')]">
            <xsl:variable name="this_subfield" select="(ancestor-or-self::*:subfield)"/>
            <xsl:variable name="anchor_subfield" select="(ancestor-or-self::*:subfield)"/>
            <xsl:variable name="this_subfield_code"
                           as="xs:string"
                           select="$this_subfield/@code"/>
            <xsl:variable name="anchor_subfield_code"
                           as="xs:string"
                           select="$this_subfield/@code"/>
            <xsl:variable name="this_subfield_position"
                           as="xs:string"
                           select="string(position())"/>
            <xsl:element name="{name(ancestor-or-self::*:record)}"
                          namespace="{namespace-uri(ancestor-or-self::*:record)}">
               <xsl:attribute name="id"
                               select="string-join(($record/@id,$this_template_name,$tag,$this_subfield_code,$this_field_position,$this_subfield_position), ':')"/>
               <xsl:attribute name="type" select="'http://rdaregistry.info/Elements/c/C10001'"/>
               <xsl:attribute name="templatename" select="$this_template_name"/>
               <xsl:for-each select="$record/*:datafield[@tag='800'][. eq $this_field][*:subfield/@code = ('t','f','n','1')]">
                  <xsl:copy>
                     <xsl:call-template name="copy-attributes"/>
                     <xsl:for-each select="*:subfield[@code = ('t','f','n','1')]">
                        <xsl:if test="@code = 't'">
                           <xsl:copy>
                              <xsl:call-template name="copy-content">
                                 <xsl:with-param name="type" select="'http://www.w3.org/2000/01/rdf-schema#label'"/>
                                 <xsl:with-param name="select"
                                                  select="frbrizer:trim(.) || ' (' || ../*:subfield[@code='a']/replace(., '[\s,/:=]+$', '') || ')'"/>
                              </xsl:call-template>
                           </xsl:copy>
                        </xsl:if>
                        <xsl:if test="@code = 't'">
                           <xsl:copy>
                              <xsl:call-template name="copy-content">
                                 <xsl:with-param name="type" select="'http://www.w3.org/2000/01/rdf-schema#label'"/>
                                 <xsl:with-param name="select" select="frbrizer:trim(.)"/>
                              </xsl:call-template>
                           </xsl:copy>
                        </xsl:if>
                        <xsl:if test="@code = 't'">
                           <xsl:copy>
                              <xsl:call-template name="copy-content">
                                 <xsl:with-param name="type"
                                                  select="'http://rdaregistry.info/Elements/w/datatype/P10088'"/>
                                 <xsl:with-param name="select"
                                                  select="string-join((frbrizer:trim(.), frbrizer:trim(../*:subfield[@code = 'p'])), ' : ')"/>
                              </xsl:call-template>
                           </xsl:copy>
                        </xsl:if>
                        <xsl:if test="@code = 'f'">
                           <xsl:copy>
                              <xsl:call-template name="copy-content">
                                 <xsl:with-param name="type"
                                                  select="'http://rdaregistry.info/Elements/w/datatype/P10219'"/>
                                 <xsl:with-param name="select" select="."/>
                              </xsl:call-template>
                           </xsl:copy>
                        </xsl:if>
                        <xsl:if test="@code = 'n'">
                           <xsl:copy>
                              <xsl:call-template name="copy-content">
                                 <xsl:with-param name="type"
                                                  select="'http://rdaregistry.info/Elements/w/datatype/P10012'"/>
                                 <xsl:with-param name="select" select="."/>
                              </xsl:call-template>
                           </xsl:copy>
                        </xsl:if>
                        <xsl:if test="@code = '1'">
                           <xsl:copy>
                              <xsl:call-template name="copy-content">
                                 <xsl:with-param name="type"
                                                  select="'http://rdaregistry.info/Elements/x/datatype/P00018'"/>
                                 <xsl:with-param name="select" select="."/>
                              </xsl:call-template>
                           </xsl:copy>
                        </xsl:if>
                     </xsl:for-each>
                  </xsl:copy>
               </xsl:for-each>
               <xsl:for-each select="$record/*:datafield[@tag='810'][. eq $this_field][*:subfield/@code = ('t','f','n','1')]">
                  <xsl:copy>
                     <xsl:call-template name="copy-attributes"/>
                     <xsl:for-each select="*:subfield[@code = ('t','f','n','1')]">
                        <xsl:if test="@code = 't'">
                           <xsl:copy>
                              <xsl:call-template name="copy-content">
                                 <xsl:with-param name="type" select="'http://www.w3.org/2000/01/rdf-schema#label'"/>
                                 <xsl:with-param name="select" select="frbrizer:trim(.)"/>
                              </xsl:call-template>
                           </xsl:copy>
                        </xsl:if>
                        <xsl:if test="@code = 't'">
                           <xsl:copy>
                              <xsl:call-template name="copy-content">
                                 <xsl:with-param name="type"
                                                  select="'http://rdaregistry.info/Elements/w/datatype/P10088'"/>
                                 <xsl:with-param name="select"
                                                  select="string-join((frbrizer:trim(.), frbrizer:trim(../*:subfield[@code = 'p'])), ' : ')"/>
                              </xsl:call-template>
                           </xsl:copy>
                        </xsl:if>
                        <xsl:if test="@code = 'f'">
                           <xsl:copy>
                              <xsl:call-template name="copy-content">
                                 <xsl:with-param name="type"
                                                  select="'http://rdaregistry.info/Elements/w/datatype/P10219'"/>
                                 <xsl:with-param name="select" select="."/>
                              </xsl:call-template>
                           </xsl:copy>
                        </xsl:if>
                        <xsl:if test="@code = 'n'">
                           <xsl:copy>
                              <xsl:call-template name="copy-content">
                                 <xsl:with-param name="type"
                                                  select="'http://rdaregistry.info/Elements/w/datatype/P10012'"/>
                                 <xsl:with-param name="select" select="."/>
                              </xsl:call-template>
                           </xsl:copy>
                        </xsl:if>
                        <xsl:if test="@code = '1'">
                           <xsl:copy>
                              <xsl:call-template name="copy-content">
                                 <xsl:with-param name="type"
                                                  select="'http://rdaregistry.info/Elements/x/datatype/P00018'"/>
                                 <xsl:with-param name="select" select="."/>
                              </xsl:call-template>
                           </xsl:copy>
                        </xsl:if>
                     </xsl:for-each>
                  </xsl:copy>
               </xsl:for-each>
               <xsl:for-each select="$record/*:datafield[@tag='811'][. eq $this_field][*:subfield/@code = ('t','f','n','1')]">
                  <xsl:copy>
                     <xsl:call-template name="copy-attributes"/>
                     <xsl:for-each select="*:subfield[@code = ('t','f','n','1')]">
                        <xsl:if test="@code = 't'">
                           <xsl:copy>
                              <xsl:call-template name="copy-content">
                                 <xsl:with-param name="type" select="'http://www.w3.org/2000/01/rdf-schema#label'"/>
                                 <xsl:with-param name="select" select="frbrizer:trim(.)"/>
                              </xsl:call-template>
                           </xsl:copy>
                        </xsl:if>
                        <xsl:if test="@code = 't'">
                           <xsl:copy>
                              <xsl:call-template name="copy-content">
                                 <xsl:with-param name="type"
                                                  select="'http://rdaregistry.info/Elements/w/datatype/P10088'"/>
                                 <xsl:with-param name="select"
                                                  select="string-join((frbrizer:trim(.), frbrizer:trim(../*:subfield[@code = 'p'])), ' : ')"/>
                              </xsl:call-template>
                           </xsl:copy>
                        </xsl:if>
                        <xsl:if test="@code = 'f'">
                           <xsl:copy>
                              <xsl:call-template name="copy-content">
                                 <xsl:with-param name="type"
                                                  select="'http://rdaregistry.info/Elements/w/datatype/P10219'"/>
                                 <xsl:with-param name="select" select="."/>
                              </xsl:call-template>
                           </xsl:copy>
                        </xsl:if>
                        <xsl:if test="@code = 'n'">
                           <xsl:copy>
                              <xsl:call-template name="copy-content">
                                 <xsl:with-param name="type"
                                                  select="'http://rdaregistry.info/Elements/w/datatype/P10012'"/>
                                 <xsl:with-param name="select" select="."/>
                              </xsl:call-template>
                           </xsl:copy>
                        </xsl:if>
                        <xsl:if test="@code = '1'">
                           <xsl:copy>
                              <xsl:call-template name="copy-content">
                                 <xsl:with-param name="type"
                                                  select="'http://rdaregistry.info/Elements/x/datatype/P00018'"/>
                                 <xsl:with-param name="select" select="."/>
                              </xsl:call-template>
                           </xsl:copy>
                        </xsl:if>
                     </xsl:for-each>
                  </xsl:copy>
               </xsl:for-each>
               <xsl:for-each select="$record/*:datafield[@tag='830'][. eq $this_field][*:subfield/@code = ('a','f','n','1')]">
                  <xsl:copy>
                     <xsl:call-template name="copy-attributes"/>
                     <xsl:for-each select="*:subfield[@code = ('a','f','n','1')]">
                        <xsl:if test="@code = 'a'">
                           <xsl:copy>
                              <xsl:call-template name="copy-content">
                                 <xsl:with-param name="type" select="'http://www.w3.org/2000/01/rdf-schema#label'"/>
                                 <xsl:with-param name="select" select="frbrizer:trim(.)"/>
                              </xsl:call-template>
                           </xsl:copy>
                        </xsl:if>
                        <xsl:if test="@code = 'a'">
                           <xsl:copy>
                              <xsl:call-template name="copy-content">
                                 <xsl:with-param name="type"
                                                  select="'http://rdaregistry.info/Elements/w/datatype/P10088'"/>
                                 <xsl:with-param name="select"
                                                  select="string-join((frbrizer:trim(.), frbrizer:trim(../*:subfield[@code = 'p'])), ' : ')"/>
                              </xsl:call-template>
                           </xsl:copy>
                        </xsl:if>
                        <xsl:if test="@code = 'f'">
                           <xsl:copy>
                              <xsl:call-template name="copy-content">
                                 <xsl:with-param name="type"
                                                  select="'http://rdaregistry.info/Elements/w/datatype/P10219'"/>
                                 <xsl:with-param name="select" select="."/>
                              </xsl:call-template>
                           </xsl:copy>
                        </xsl:if>
                        <xsl:if test="@code = 'n'">
                           <xsl:copy>
                              <xsl:call-template name="copy-content">
                                 <xsl:with-param name="type"
                                                  select="'http://rdaregistry.info/Elements/w/datatype/P10012'"/>
                                 <xsl:with-param name="select" select="."/>
                              </xsl:call-template>
                           </xsl:copy>
                        </xsl:if>
                        <xsl:if test="@code = '1'">
                           <xsl:copy>
                              <xsl:call-template name="copy-content">
                                 <xsl:with-param name="type"
                                                  select="'http://rdaregistry.info/Elements/x/datatype/P00018'"/>
                                 <xsl:with-param name="select" select="."/>
                              </xsl:call-template>
                           </xsl:copy>
                        </xsl:if>
                     </xsl:for-each>
                  </xsl:copy>
               </xsl:for-each>
            </xsl:element>
         </xsl:for-each>
      </xsl:for-each>
   </xsl:template>
   <xsl:template name="MARC336">
      <xsl:variable name="this_template_name" select="'MARC336'"/>
      <xsl:variable name="tag" as="xs:string" select="'336'"/>
      <xsl:variable name="code" as="xs:string" select="'0'"/>
      <xsl:variable name="record" select="."/>
      <xsl:variable name="marcid" select="*:controlfield[@tag='001']"/>
      <xsl:for-each select="node()[@tag=('336')]">
         <xsl:variable name="this_field"
                        select="(ancestor-or-self::*:datafield, ancestor-or-self::*:controlfield)"/>
         <xsl:variable name="this"
                        select="(ancestor-or-self::*:datafield, ancestor-or-self::*:controlfield)"/>
         <xsl:variable name="anchor_field"
                        select="(ancestor-or-self::*:datafield, ancestor-or-self::*:controlfield)"/>
         <xsl:variable name="anchor"
                        as="xs:string"
                        select="(ancestor-or-self::*:datafield, ancestor-or-self::*:controlfield)"/>
         <xsl:variable name="this_field_position"
                        as="xs:string"
                        select="string(position())"/>
         <xsl:for-each select="node()[@code=('0')][starts-with(., 'http')]">
            <xsl:variable name="this_subfield" select="(ancestor-or-self::*:subfield)"/>
            <xsl:variable name="anchor_subfield" select="(ancestor-or-self::*:subfield)"/>
            <xsl:variable name="this_subfield_code"
                           as="xs:string"
                           select="$this_subfield/@code"/>
            <xsl:variable name="anchor_subfield_code"
                           as="xs:string"
                           select="$this_subfield/@code"/>
            <xsl:variable name="this_subfield_position"
                           as="xs:string"
                           select="string(position())"/>
            <xsl:element name="{name(ancestor-or-self::*:record)}"
                          namespace="{namespace-uri(ancestor-or-self::*:record)}">
               <xsl:attribute name="id"
                               select="string-join(($record/@id,$this_template_name,$tag,$this_subfield_code,$this_field_position,$this_subfield_position), ':')"/>
               <xsl:attribute name="type" select="'http://www.w3.org/2004/02/skos/core#Concept'"/>
               <xsl:attribute name="templatename" select="$this_template_name"/>
               <xsl:for-each select="$record/*:datafield[@tag='336'][generate-id(.) = generate-id($this_field)][*:subfield/@code = ('0')]">
                  <xsl:copy>
                     <xsl:call-template name="copy-attributes"/>
                     <xsl:for-each select="*:subfield[@code = ('0')]">
                        <xsl:if test="@code = '0' and generate-id(.) = generate-id($this_subfield)">
                           <xsl:copy>
                              <xsl:call-template name="copy-content">
                                 <xsl:with-param name="type"
                                                  select="'http://www.w3.org/2004/02/skos/core#subjectIndicator'"/>
                                 <xsl:with-param name="select" select="."/>
                              </xsl:call-template>
                           </xsl:copy>
                        </xsl:if>
                     </xsl:for-each>
                  </xsl:copy>
               </xsl:for-each>
            </xsl:element>
         </xsl:for-each>
      </xsl:for-each>
   </xsl:template>
   <xsl:template name="MARC337">
      <xsl:variable name="this_template_name" select="'MARC337'"/>
      <xsl:variable name="tag" as="xs:string" select="'337'"/>
      <xsl:variable name="code" as="xs:string" select="'0'"/>
      <xsl:variable name="record" select="."/>
      <xsl:variable name="marcid" select="*:controlfield[@tag='001']"/>
      <xsl:for-each select="node()[@tag=('337')]">
         <xsl:variable name="this_field"
                        select="(ancestor-or-self::*:datafield, ancestor-or-self::*:controlfield)"/>
         <xsl:variable name="this"
                        select="(ancestor-or-self::*:datafield, ancestor-or-self::*:controlfield)"/>
         <xsl:variable name="anchor_field"
                        select="(ancestor-or-self::*:datafield, ancestor-or-self::*:controlfield)"/>
         <xsl:variable name="anchor"
                        as="xs:string"
                        select="(ancestor-or-self::*:datafield, ancestor-or-self::*:controlfield)"/>
         <xsl:variable name="this_field_position"
                        as="xs:string"
                        select="string(position())"/>
         <xsl:for-each select="node()[@code=('0')][starts-with(., 'http')]">
            <xsl:variable name="this_subfield" select="(ancestor-or-self::*:subfield)"/>
            <xsl:variable name="anchor_subfield" select="(ancestor-or-self::*:subfield)"/>
            <xsl:variable name="this_subfield_code"
                           as="xs:string"
                           select="$this_subfield/@code"/>
            <xsl:variable name="anchor_subfield_code"
                           as="xs:string"
                           select="$this_subfield/@code"/>
            <xsl:variable name="this_subfield_position"
                           as="xs:string"
                           select="string(position())"/>
            <xsl:element name="{name(ancestor-or-self::*:record)}"
                          namespace="{namespace-uri(ancestor-or-self::*:record)}">
               <xsl:attribute name="id"
                               select="string-join(($record/@id,$this_template_name,$tag,$this_subfield_code,$this_field_position,$this_subfield_position), ':')"/>
               <xsl:attribute name="type" select="'http://www.w3.org/2004/02/skos/core#Concept'"/>
               <xsl:attribute name="templatename" select="$this_template_name"/>
               <xsl:for-each select="$record/*:datafield[@tag='337'][generate-id(.) = generate-id($this_field)][*:subfield/@code = ('0')]">
                  <xsl:copy>
                     <xsl:call-template name="copy-attributes"/>
                     <xsl:for-each select="*:subfield[@code = ('0')]">
                        <xsl:if test="@code = '0' and generate-id(.) = generate-id($this_subfield)">
                           <xsl:copy>
                              <xsl:call-template name="copy-content">
                                 <xsl:with-param name="type"
                                                  select="'http://www.w3.org/2004/02/skos/core#subjectIndicator'"/>
                                 <xsl:with-param name="select" select="."/>
                              </xsl:call-template>
                           </xsl:copy>
                        </xsl:if>
                     </xsl:for-each>
                  </xsl:copy>
               </xsl:for-each>
            </xsl:element>
         </xsl:for-each>
      </xsl:for-each>
   </xsl:template>
   <xsl:template name="MARC338">
      <xsl:variable name="this_template_name" select="'MARC338'"/>
      <xsl:variable name="tag" as="xs:string" select="'338'"/>
      <xsl:variable name="code" as="xs:string" select="'0'"/>
      <xsl:variable name="record" select="."/>
      <xsl:variable name="marcid" select="*:controlfield[@tag='001']"/>
      <xsl:for-each select="node()[@tag=('338')]">
         <xsl:variable name="this_field"
                        select="(ancestor-or-self::*:datafield, ancestor-or-self::*:controlfield)"/>
         <xsl:variable name="this"
                        select="(ancestor-or-self::*:datafield, ancestor-or-self::*:controlfield)"/>
         <xsl:variable name="anchor_field"
                        select="(ancestor-or-self::*:datafield, ancestor-or-self::*:controlfield)"/>
         <xsl:variable name="anchor"
                        as="xs:string"
                        select="(ancestor-or-self::*:datafield, ancestor-or-self::*:controlfield)"/>
         <xsl:variable name="this_field_position"
                        as="xs:string"
                        select="string(position())"/>
         <xsl:for-each select="node()[@code=('0')][starts-with(., 'http')]">
            <xsl:variable name="this_subfield" select="(ancestor-or-self::*:subfield)"/>
            <xsl:variable name="anchor_subfield" select="(ancestor-or-self::*:subfield)"/>
            <xsl:variable name="this_subfield_code"
                           as="xs:string"
                           select="$this_subfield/@code"/>
            <xsl:variable name="anchor_subfield_code"
                           as="xs:string"
                           select="$this_subfield/@code"/>
            <xsl:variable name="this_subfield_position"
                           as="xs:string"
                           select="string(position())"/>
            <xsl:element name="{name(ancestor-or-self::*:record)}"
                          namespace="{namespace-uri(ancestor-or-self::*:record)}">
               <xsl:attribute name="id"
                               select="string-join(($record/@id,$this_template_name,$tag,$this_subfield_code,$this_field_position,$this_subfield_position), ':')"/>
               <xsl:attribute name="type" select="'http://www.w3.org/2004/02/skos/core#Concept'"/>
               <xsl:attribute name="templatename" select="$this_template_name"/>
               <xsl:for-each select="$record/*:datafield[@tag='338'][generate-id(.) = generate-id($this_field)][*:subfield/@code = ('0')]">
                  <xsl:copy>
                     <xsl:call-template name="copy-attributes"/>
                     <xsl:for-each select="*:subfield[@code = ('0')]">
                        <xsl:if test="@code = '0' and generate-id(.) = generate-id($this_subfield)">
                           <xsl:copy>
                              <xsl:call-template name="copy-content">
                                 <xsl:with-param name="type"
                                                  select="'http://www.w3.org/2004/02/skos/core#subjectIndicator'"/>
                                 <xsl:with-param name="select" select="."/>
                              </xsl:call-template>
                           </xsl:copy>
                        </xsl:if>
                     </xsl:for-each>
                  </xsl:copy>
               </xsl:for-each>
            </xsl:element>
         </xsl:for-each>
      </xsl:for-each>
   </xsl:template>
   <xsl:template name="MARC380">
      <xsl:variable name="this_template_name" select="'MARC380'"/>
      <xsl:variable name="tag" as="xs:string" select="'380'"/>
      <xsl:variable name="code" as="xs:string" select="'0'"/>
      <xsl:variable name="record" select="."/>
      <xsl:variable name="marcid" select="*:controlfield[@tag='001']"/>
      <xsl:for-each select="node()[@tag=('380')]">
         <xsl:variable name="this_field"
                        select="(ancestor-or-self::*:datafield, ancestor-or-self::*:controlfield)"/>
         <xsl:variable name="this"
                        select="(ancestor-or-self::*:datafield, ancestor-or-self::*:controlfield)"/>
         <xsl:variable name="anchor_field"
                        select="(ancestor-or-self::*:datafield, ancestor-or-self::*:controlfield)"/>
         <xsl:variable name="anchor"
                        as="xs:string"
                        select="(ancestor-or-self::*:datafield, ancestor-or-self::*:controlfield)"/>
         <xsl:variable name="this_field_position"
                        as="xs:string"
                        select="string(position())"/>
         <xsl:for-each select="node()[@code=('0')][starts-with(., 'http')]">
            <xsl:variable name="this_subfield" select="(ancestor-or-self::*:subfield)"/>
            <xsl:variable name="anchor_subfield" select="(ancestor-or-self::*:subfield)"/>
            <xsl:variable name="this_subfield_code"
                           as="xs:string"
                           select="$this_subfield/@code"/>
            <xsl:variable name="anchor_subfield_code"
                           as="xs:string"
                           select="$this_subfield/@code"/>
            <xsl:variable name="this_subfield_position"
                           as="xs:string"
                           select="string(position())"/>
            <xsl:element name="{name(ancestor-or-self::*:record)}"
                          namespace="{namespace-uri(ancestor-or-self::*:record)}">
               <xsl:attribute name="id"
                               select="string-join(($record/@id,$this_template_name,$tag,$this_subfield_code,$this_field_position,$this_subfield_position), ':')"/>
               <xsl:attribute name="type" select="'http://www.w3.org/2004/02/skos/core#Concept'"/>
               <xsl:attribute name="templatename" select="$this_template_name"/>
               <xsl:for-each select="$record/*:datafield[@tag='380'][generate-id(.) = generate-id($this_field)][*:subfield/@code = ('0')]">
                  <xsl:copy>
                     <xsl:call-template name="copy-attributes"/>
                     <xsl:for-each select="*:subfield[@code = ('0')]">
                        <xsl:if test="@code = '0' and generate-id(.) = generate-id($this_subfield)">
                           <xsl:copy>
                              <xsl:call-template name="copy-content">
                                 <xsl:with-param name="type"
                                                  select="'http://www.w3.org/2004/02/skos/core#subjectIndicator'"/>
                                 <xsl:with-param name="select" select="."/>
                              </xsl:call-template>
                           </xsl:copy>
                        </xsl:if>
                     </xsl:for-each>
                  </xsl:copy>
               </xsl:for-each>
            </xsl:element>
         </xsl:for-each>
      </xsl:for-each>
   </xsl:template>
   <xsl:template match="frbrizer:record-set" mode="create-key-mapping-step-1">
      <frbrizer:keymap>
         <xsl:for-each select="*:record">
            <xsl:choose>
               <xsl:when test="@templatename = 'MARC380'">
                  <xsl:element name="frbrizer:keyentry">
                     <xsl:variable name="key" as="xs:string*">
                        <xsl:value-of select="frbrizer:sort-keys(*:datafield[@tag=('380')]/*:subfield[@code='0'][starts-with(., 'http')])"/>
                     </xsl:variable>
                     <xsl:variable name="keyvalue"
                                    select="replace(string-join($key[. != ''], '/'), ' ', '')"/>
                     <xsl:attribute name="key" select="$keyvalue"/>
                     <xsl:attribute name="id" select="@id"/>
                  </xsl:element>
               </xsl:when>
               <xsl:when test="@templatename = 'MARC336'">
                  <xsl:element name="frbrizer:keyentry">
                     <xsl:variable name="key" as="xs:string*">
                        <xsl:value-of select="frbrizer:sort-keys(*:datafield[@tag=('336')]/*:subfield[@code='0'][starts-with(., 'http')])"/>
                     </xsl:variable>
                     <xsl:variable name="keyvalue"
                                    select="replace(string-join($key[. != ''], '/'), ' ', '')"/>
                     <xsl:attribute name="key" select="$keyvalue"/>
                     <xsl:attribute name="id" select="@id"/>
                  </xsl:element>
               </xsl:when>
               <xsl:when test="@templatename = 'MARC337'">
                  <xsl:element name="frbrizer:keyentry">
                     <xsl:variable name="key" as="xs:string*">
                        <xsl:value-of select="frbrizer:sort-keys(*:datafield[@tag=('337')]/*:subfield[@code='0'][starts-with(., 'http')])"/>
                     </xsl:variable>
                     <xsl:variable name="keyvalue"
                                    select="replace(string-join($key[. != ''], '/'), ' ', '')"/>
                     <xsl:attribute name="key" select="$keyvalue"/>
                     <xsl:attribute name="id" select="@id"/>
                  </xsl:element>
               </xsl:when>
               <xsl:when test="@templatename = 'MARC338'">
                  <xsl:element name="frbrizer:keyentry">
                     <xsl:variable name="key" as="xs:string*">
                        <xsl:value-of select="frbrizer:sort-keys(*:datafield[@tag=('338')]/*:subfield[@code='0'][starts-with(., 'http')])"/>
                     </xsl:variable>
                     <xsl:variable name="keyvalue"
                                    select="replace(string-join($key[. != ''], '/'), ' ', '')"/>
                     <xsl:attribute name="key" select="$keyvalue"/>
                     <xsl:attribute name="id" select="@id"/>
                  </xsl:element>
               </xsl:when>
               <xsl:when test="@templatename = 'MARC041'">
                  <xsl:element name="frbrizer:keyentry">
                     <xsl:variable name="key" as="xs:string*">
                        <xsl:value-of select="frbrizer:sort-keys(concat('http://id.loc.gov/vocabulary/iso639-2/', (*:datafield[@tag=('041')]/*:subfield[@code=('a', 'd')])[1]))"/>
                     </xsl:variable>
                     <xsl:variable name="keyvalue"
                                    select="replace(string-join($key[. != ''], '/'), ' ', '')"/>
                     <xsl:attribute name="key" select="$keyvalue"/>
                     <xsl:attribute name="id" select="@id"/>
                  </xsl:element>
               </xsl:when>
               <xsl:when test="@templatename = 'MARC041additional'">
                  <xsl:element name="frbrizer:keyentry">
                     <xsl:variable name="key" as="xs:string*">
                        <xsl:value-of select="frbrizer:sort-keys(concat('http://id.loc.gov/vocabulary/iso639-2/', (*:datafield[@tag=('041')]/*:subfield[@code=('b', 'e', 'f', 'g', 'i', 'j', 'k', 'l', 'm', 'n', 'p', 'q', 'r', 't')])[1]))"/>
                     </xsl:variable>
                     <xsl:variable name="keyvalue"
                                    select="replace(string-join($key[. != ''], '/'), ' ', '')"/>
                     <xsl:attribute name="key" select="$keyvalue"/>
                     <xsl:attribute name="id" select="@id"/>
                  </xsl:element>
               </xsl:when>
               <xsl:when test="@templatename = 'MARC008language'">
                  <xsl:element name="frbrizer:keyentry">
                     <xsl:variable name="key" as="xs:string*">
                        <xsl:value-of select="frbrizer:sort-keys(concat('http://id.loc.gov/vocabulary/iso639-2/', *:controlfield[@tag=('008')]))"/>
                     </xsl:variable>
                     <xsl:variable name="keyvalue"
                                    select="replace(string-join($key[. != ''], '/'), ' ', '')"/>
                     <xsl:attribute name="key" select="$keyvalue"/>
                     <xsl:attribute name="id" select="@id"/>
                  </xsl:element>
               </xsl:when>
               <xsl:when test="@templatename = 'MARC21-100700Person'">
                  <xsl:element name="frbrizer:keyentry">
                     <xsl:variable name="key" as="xs:string*">
                        <xsl:value-of select="frbrizer:sort-keys(frbrizer:trim(*:datafield[@tag=('100', '110', '111', '700', '710', '711')]/*:subfield[@code='1'][starts-with(., 'http')][1]))"/>
                     </xsl:variable>
                     <xsl:variable name="keyvalue"
                                    select="replace(string-join($key[. != ''], '/'), ' ', '')"/>
                     <xsl:attribute name="key" select="$keyvalue"/>
                     <xsl:attribute name="id" select="@id"/>
                  </xsl:element>
               </xsl:when>
               <xsl:when test="@templatename = 'MARC21-130240-Work'">
                  <xsl:element name="frbrizer:keyentry">
                     <xsl:variable name="key" as="xs:string*">
                        <xsl:value-of select="frbrizer:sort-keys(frbrizer:trim(*:datafield[@tag=('130', '240')]/*:subfield[@code='1'][starts-with(., 'http')][last()]))"/>
                     </xsl:variable>
                     <xsl:variable name="keyvalue"
                                    select="replace(string-join($key[. != ''], '/'), ' ', '')"/>
                     <xsl:attribute name="key" select="$keyvalue"/>
                     <xsl:attribute name="id" select="@id"/>
                  </xsl:element>
               </xsl:when>
               <xsl:when test="@templatename = 'MARC21-600-Person'">
                  <xsl:element name="frbrizer:keyentry">
                     <xsl:variable name="key" as="xs:string*">
                        <xsl:value-of select="frbrizer:sort-keys(frbrizer:trim(*:datafield[@tag=('600', '610', '611')]/*:subfield[@code='1'][starts-with(., 'http')][1]))"/>
                     </xsl:variable>
                     <xsl:variable name="keyvalue"
                                    select="replace(string-join($key[. != ''], '/'), ' ', '')"/>
                     <xsl:attribute name="key" select="$keyvalue"/>
                     <xsl:attribute name="id" select="@id"/>
                  </xsl:element>
               </xsl:when>
               <xsl:when test="@templatename = 'MARC21-6XX-Work'">
                  <xsl:element name="frbrizer:keyentry">
                     <xsl:variable name="key" as="xs:string*">
                        <xsl:value-of select="frbrizer:sort-keys(frbrizer:trim(*:datafield[@tag=('600', '610', '611', '630')]/*:subfield[@code='1'][starts-with(., 'http')][1]))"/>
                     </xsl:variable>
                     <xsl:variable name="keyvalue"
                                    select="replace(string-join($key[. != ''], '/'), ' ', '')"/>
                     <xsl:attribute name="key" select="$keyvalue"/>
                     <xsl:attribute name="id" select="@id"/>
                  </xsl:element>
               </xsl:when>
               <xsl:when test="@templatename = 'MARC21-700-Related-Work'">
                  <xsl:element name="frbrizer:keyentry">
                     <xsl:variable name="key" as="xs:string*">
                        <xsl:value-of select="frbrizer:sort-keys(frbrizer:trim(*:datafield[@tag=('700', '710', '711', '730')]/*:subfield[@code='1'][starts-with(.,'http')][last()]))"/>
                     </xsl:variable>
                     <xsl:variable name="keyvalue"
                                    select="replace(string-join($key[. != ''], '/'), ' ', '')"/>
                     <xsl:attribute name="key" select="$keyvalue"/>
                     <xsl:attribute name="id" select="@id"/>
                  </xsl:element>
               </xsl:when>
               <xsl:when test="@templatename = 'MARC21-700-Work-Analytical'">
                  <xsl:element name="frbrizer:keyentry">
                     <xsl:variable name="key" as="xs:string*">
                        <xsl:value-of select="frbrizer:sort-keys(frbrizer:trim(*:datafield[@tag=('700', '710', '711', '730')]/*:subfield[@code='1'][starts-with(., 'http')][last()]))"/>
                     </xsl:variable>
                     <xsl:variable name="keyvalue"
                                    select="replace(string-join($key[. != ''], '/'), ' ', '')"/>
                     <xsl:attribute name="key" select="$keyvalue"/>
                     <xsl:attribute name="id" select="@id"/>
                  </xsl:element>
               </xsl:when>
               <xsl:when test="@templatename = 'MARC21-758-Related-Work'">
                  <xsl:element name="frbrizer:keyentry">
                     <xsl:variable name="key" as="xs:string*">
                        <xsl:value-of select="frbrizer:sort-keys(frbrizer:trim(*:datafield[@tag=('758')]/*:subfield[@code='1'][starts-with(., 'http')][1]))"/>
                     </xsl:variable>
                     <xsl:variable name="keyvalue"
                                    select="replace(string-join($key[. != ''], '/'), ' ', '')"/>
                     <xsl:attribute name="key" select="$keyvalue"/>
                     <xsl:attribute name="id" select="@id"/>
                  </xsl:element>
               </xsl:when>
               <xsl:when test="@templatename = 'MARC21-8XX-Work-Series'">
                  <xsl:element name="frbrizer:keyentry">
                     <xsl:variable name="key" as="xs:string*">
                        <xsl:value-of select="frbrizer:sort-keys(frbrizer:trim(*:datafield[@tag=('800', '810', '811', '830')]/*:subfield[@code='1'][starts-with(.,'http')][last()]))"/>
                     </xsl:variable>
                     <xsl:variable name="keyvalue"
                                    select="replace(string-join($key[. != ''], '/'), ' ', '')"/>
                     <xsl:attribute name="key" select="$keyvalue"/>
                     <xsl:attribute name="id" select="@id"/>
                  </xsl:element>
               </xsl:when>
            </xsl:choose>
         </xsl:for-each>
      </frbrizer:keymap>
   </xsl:template>
   <xsl:template match="frbrizer:record-set" mode="create-key-mapping-step-2">
      <frbrizer:keymap>
         <xsl:for-each select="*:record">
            <xsl:choose>
               <xsl:when test="@templatename = 'MARC21-130240-Expression'">
                  <xsl:element name="frbrizer:keyentry">
                     <xsl:variable name="key" as="xs:string*">
                        <xsl:value-of select="frbrizer:sort-keys((frbrizer:sort-relationships(*:relationship[@type = 'http://rdaregistry.info/Elements/e/object/P20231']/@href))[1])"/>
                        <xsl:value-of select="frbrizer:sort-keys('exp')"/>
                        <xsl:value-of select="frbrizer:sort-keys(if (*:relationship[@type = 'http://rdaregistry.info/Elements/e/datatype/P20001']/@href = 'http://rdaregistry.info/termList/RDAContentType/1023') then () else string-join(frbrizer:trimsort-targets(*:relationship[@type =('http://rdaregistry.info/Elements/e/datatype/P20006')]/@href), '/'))"/>
                        <xsl:value-of select="frbrizer:sort-keys(string-join(frbrizer:trimsort-targets(*:relationship[@type =('http://rdaregistry.info/Elements/e/datatype/P20001')]/@href), '/'))"/>
                        <xsl:value-of select="frbrizer:sort-keys(string-join(frbrizer:trimsort-targets(*:relationship[@type =('http://rdaregistry.info/Elements/e/object/P20037', 'http://rdaregistry.info/Elements/e/object/P20022', 'http://rdaregistry.info/Elements/e/object/P20049', 'http://rdaregistry.info/Elements/e/object/P20330')]/@href), '/'))"/>
                     </xsl:variable>
                     <xsl:variable name="keyvalue"
                                    select="replace(string-join($key[. != ''], '/'), ' ', '')"/>
                     <xsl:attribute name="key" select="$keyvalue"/>
                     <xsl:attribute name="id" select="@id"/>
                  </xsl:element>
               </xsl:when>
               <xsl:when test="@templatename = 'MARC21-245-Manifestation'">
                  <xsl:element name="frbrizer:keyentry">
                     <xsl:variable name="key" as="xs:string*">
                        <xsl:value-of select="frbrizer:sort-keys(if ((*:datafield[@tag=('020','022','024')][1]/*:subfield[@type = 'http://rdaregistry.info/Elements/x/datatype/P00018'])[1]) then (*:datafield[@tag=('020','022','024')][1]/*:subfield[@type='http://rdaregistry.info/Elements/x/datatype/P00018'])[1]/replace(., '\(.*\)', '') else if (*:controlfield[@tag=('001')]) then *:controlfield[@tag=('001')][1] else replace(*:datafield[@tag='245']/*:subfield[@code='a'],  '[^a-zA-Z0-9 -]', '' ) || '-' || generate-id(.))"/>
                     </xsl:variable>
                     <xsl:variable name="keyvalue"
                                    select="replace(string-join($key[. != ''], '/'), ' ', '')"/>
                     <xsl:attribute name="key" select="$keyvalue"/>
                     <xsl:attribute name="id" select="@id"/>
                  </xsl:element>
               </xsl:when>
               <xsl:when test="@templatename = 'MARC21-700-Expression-Analytical'">
                  <xsl:element name="frbrizer:keyentry">
                     <xsl:variable name="key" as="xs:string*">
                        <xsl:value-of select="frbrizer:sort-keys((frbrizer:sort-relationships(*:relationship[@type = 'http://rdaregistry.info/Elements/e/object/P20231']/@href))[1])"/>
                        <xsl:value-of select="frbrizer:sort-keys('exp')"/>
                        <xsl:value-of select="frbrizer:sort-keys(string-join(frbrizer:trimsort-targets(*:relationship[@type =('http://rdaregistry.info/Elements/e/datatype/P20006')]/@href), '/'))"/>
                        <xsl:value-of select="frbrizer:sort-keys(string-join(frbrizer:trimsort-targets(*:relationship[@type =('http://rdaregistry.info/Elements/e/datatype/P20001')]/@href), '/'))"/>
                        <xsl:value-of select="frbrizer:sort-keys(string-join(frbrizer:trimsort-targets(*:relationship[@type =('http://rdaregistry.info/Elements/e/object/P20037', 'http://rdaregistry.info/Elements/e/object/P20022', 'http://rdaregistry.info/Elements/e/object/P20049', 'http://rdaregistry.info/Elements/e/object/P20330')]/@href), '/'))"/>
                     </xsl:variable>
                     <xsl:variable name="keyvalue"
                                    select="replace(string-join($key[. != ''], '/'), ' ', '')"/>
                     <xsl:attribute name="key" select="$keyvalue"/>
                     <xsl:attribute name="id" select="@id"/>
                  </xsl:element>
               </xsl:when>
            </xsl:choose>
         </xsl:for-each>
      </frbrizer:keymap>
   </xsl:template>
   <xsl:template match="*:record-set" mode="create-keys">
      <xsl:variable name="set-phase-0" select="."/>
      <xsl:variable name="keys-phase-1">
         <xsl:apply-templates select="$set-phase-0" mode="create-key-mapping-step-1"/>
      </xsl:variable>
      <xsl:variable name="set-phase-1">
         <xsl:apply-templates select="$set-phase-0" mode="replace-keys">
            <xsl:with-param name="keymapping" select="$keys-phase-1"/>
         </xsl:apply-templates>
      </xsl:variable>
      <xsl:variable name="keys-phase-2">
         <xsl:apply-templates select="$set-phase-1" mode="create-key-mapping-step-2"/>
      </xsl:variable>
      <xsl:variable name="set-phase-2">
         <xsl:apply-templates select="$set-phase-1" mode="replace-keys">
            <xsl:with-param name="keymapping" select="$keys-phase-2"/>
         </xsl:apply-templates>
      </xsl:variable>
      <xsl:copy-of select="$set-phase-2"/>
   </xsl:template>
   <xsl:template xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
                  xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
                  name="copy-content">
      <xsl:param name="type" required="no" select="''"/>
      <xsl:param name="subtype" required="no" select="''"/>
      <xsl:param name="label" required="no" select="''"/>
      <xsl:param name="select" required="no"/>
      <xsl:param name="marcid" required="no"/>
      <xsl:call-template name="copy-attributes"/>
      <xsl:if test="$type ne ''">
         <xsl:attribute name="type" select="$type"/>
      </xsl:if>
      <xsl:if test="$subtype ne ''">
         <xsl:attribute name="subtype" select="$subtype"/>
      </xsl:if>
      <!--<xsl:if test="$include_labels and ($label ne '')">
            <xsl:if test="$label ne ''">
                <xsl:attribute name="label" select="$label"/>
            </xsl:if>
        </xsl:if>-->
      <xsl:value-of select="normalize-space($select)"/>
      <xsl:if test="$include_MARC001_in_controlfield">
         <xsl:if test="string($marcid) ne ''">
            <xsl:element name="frbrizer:mid">
               <xsl:attribute name="i" select="$marcid"/>
            </xsl:element>
         </xsl:if>
      </xsl:if>
   </xsl:template>
   <xsl:template xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
                  xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
                  name="copy-attributes">
      <xsl:for-each select="@*">
         <xsl:copy/>
      </xsl:for-each>
   </xsl:template>
   <xsl:template xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
                  xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
                  match="*:record-set"
                  mode="replace-keys"
                  name="replace-keys">
      <xsl:param name="keymapping" required="yes"/>
      <xsl:copy>
         <xsl:call-template name="copy-attributes"/>
         <xsl:for-each select="*:record">
            <xsl:variable name="record_id" select="@id"/>
            <xsl:choose>
               <xsl:when test="$keymapping//*:keyentry[@id = $record_id]">
                  <xsl:copy>
                     <xsl:for-each select="@*">
                        <xsl:choose>
                           <xsl:when test="local-name() = 'id'">
                              <xsl:attribute name="id" select="$keymapping//*:keyentry[@id = $record_id]/@key"/>
                           </xsl:when>
                           <xsl:otherwise>
                              <xsl:copy-of select="."/>
                           </xsl:otherwise>
                        </xsl:choose>
                     </xsl:for-each>
                     <xsl:if test="$include_sourceinfo">
                        <xsl:element name="frbrizer:source">
                           <xsl:attribute name="c" select="1"/>
                           <xsl:value-of select="$record_id"/>
                        </xsl:element>
                     </xsl:if>
                     <xsl:if test="$include_keyvalues">
                        <xsl:element name="frbrizer:keyvalue">
                           <xsl:if test="$include_counters">
                              <xsl:attribute name="f.c" select="1"/>
                           </xsl:if>
                           <xsl:value-of select="$keymapping//*:keyentry[@id = $record_id]/@key"/>
                        </xsl:element>
                     </xsl:if>
                     <xsl:if test="$include_id_as_element">
                        <xsl:element name="frbrizer:idvalue">
                           <xsl:attribute name="c" select="'1'"/>
                           <xsl:attribute name="id" select="$keymapping//*:keyentry[@id = $record_id]/@key"/>
                           <xsl:value-of select="$keymapping//*:keyentry[@id = $record_id]/@key"/>
                        </xsl:element>
                     </xsl:if>
                     <xsl:for-each select="node()">
                        <xsl:choose>
                           <xsl:when test="@href = $keymapping//*:keyentry/@id">
                              <xsl:variable name="temp" select="@href"/>
                              <xsl:copy>
                                 <xsl:for-each select="@*">
                                    <xsl:choose>
                                       <xsl:when test="local-name() = 'href'">
                                          <xsl:attribute name="href" select="$keymapping//*:keyentry[@id = $temp]/@key"/>
                                       </xsl:when>
                                       <xsl:otherwise>
                                          <xsl:copy-of select="."/>
                                       </xsl:otherwise>
                                    </xsl:choose>
                                 </xsl:for-each>
                                 <xsl:for-each select="node()">
                                    <xsl:copy-of select="."/>
                                 </xsl:for-each>
                              </xsl:copy>
                           </xsl:when>
                           <xsl:otherwise>
                              <xsl:copy-of select="."/>
                           </xsl:otherwise>
                        </xsl:choose>
                     </xsl:for-each>
                  </xsl:copy>
               </xsl:when>
               <xsl:when test="exists(*:relationship[@href = $keymapping//*:keyentry/@id])">
                  <xsl:copy>
                     <xsl:call-template name="copy-attributes"/>
                     <xsl:for-each select="node()">
                        <xsl:choose>
                           <xsl:when test="local-name() = 'relationship'">
                              <xsl:variable name="href" select="@href"/>
                              <xsl:copy>
                                 <xsl:for-each select="@*">
                                    <xsl:choose>
                                       <xsl:when test="local-name() = 'href' and exists($keymapping//*:keyentry[@id = $href]/@key)">
                                          <xsl:attribute name="href" select="$keymapping//*:keyentry[@id = $href]/@key[1]"/>
                                       </xsl:when>
                                       <xsl:otherwise>
                                          <xsl:copy-of select="."/>
                                       </xsl:otherwise>
                                    </xsl:choose>
                                 </xsl:for-each>
                                 <xsl:copy-of select="frbrizer:mid"/>
                              </xsl:copy>
                           </xsl:when>
                           <xsl:otherwise>
                              <xsl:copy-of select="."/>
                           </xsl:otherwise>
                        </xsl:choose>
                     </xsl:for-each>
                  </xsl:copy>
               </xsl:when>
               <xsl:otherwise>
                  <xsl:copy-of select="."/>
               </xsl:otherwise>
            </xsl:choose>
         </xsl:for-each>
      </xsl:copy>
   </xsl:template>
   <xsl:template xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
                  xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
                  match="*:record-set"
                  mode="create-inverse-relationships">
      <xsl:if test="$include_missing_reverse_relationships">
         <xsl:variable name="record-set" select="."/>
         <xsl:copy>
            <xsl:for-each select="*:record">
               <xsl:variable name="record" select="."/>
               <xsl:variable name="this-entity-id" select="@id"/>
               <xsl:copy>
                  <xsl:copy-of select="@* | node()"/>
                  <xsl:for-each select="$record-set/*:record[*:relationship[(@href = $this-entity-id)]]">
                     <xsl:variable name="target-entity-type" select="@type"/>
                     <xsl:variable name="target-entity-label" select="@label"/>
                     <xsl:variable name="target-entity-id" select="@id"/>
                     <xsl:for-each select="*:relationship[(@href eq $this-entity-id) and exists(@itype)]">
                        <xsl:variable name="rel-type" select="@type"/>
                        <xsl:variable name="rel-itype" select="@itype"/>
                        <xsl:if test="not(exists($record/*:relationship[@href eq $target-entity-id and @itype = $rel-type and @type = $rel-itype]))">
                           <xsl:copy>
                              <xsl:if test="exists(@itype)">
                                 <xsl:attribute name="type" select="@itype"/>
                              </xsl:if>
                              <xsl:if test="exists(@type)">
                                 <xsl:attribute name="itype" select="@type"/>
                              </xsl:if>
                              <xsl:if test="exists(@isubtype)">
                                 <xsl:attribute name="subtype" select="@isubtype"/>
                              </xsl:if>
                              <xsl:if test="exists(@subtype)">
                                 <xsl:attribute name="isubtype" select="@subtype"/>
                              </xsl:if>
                              <!--<xsl:if test="$include_target_entity_type">
                                            <xsl:attribute name="target_type" select="$target-entity-type"/>
                                        </xsl:if>-->
                              <xsl:if test="$include_counters">
                                 <xsl:attribute name="c" select="'1'"/>
                              </xsl:if>
                              <xsl:attribute name="href" select="$target-entity-id"/>
                              <!--<xsl:if test="$include_labels">
                                            <xsl:if test="@ilabel ne ''">
                                                <xsl:attribute name="label" select="@ilabel"/>
                                            </xsl:if>
                                            <xsl:if test="@label ne ''">
                                                <xsl:attribute name="ilabel" select="@label"/>
                                            </xsl:if>
                                        </xsl:if>-->
                              <xsl:copy-of select="node()"/>
                           </xsl:copy>
                        </xsl:if>
                     </xsl:for-each>
                  </xsl:for-each>
               </xsl:copy>
            </xsl:for-each>
         </xsl:copy>
      </xsl:if>
   </xsl:template>
   <xsl:template xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
                  xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
                  match="/*:collection"
                  mode="merge"
                  name="merge">
      <xsl:param name="ignore_indicators_in_merge" select="false()" required="no"/>
      <xsl:copy>
         <xsl:for-each-group select="//*:record" group-by="@id">
            <xsl:sort select="@type"/>
            <xsl:sort select="@subtype"/>
            <xsl:sort select="@id"/>
            <xsl:element name="{name(current-group()[1])}"
                          namespace="{namespace-uri(current-group()[1])}">
               <xsl:attribute name="id" select="current-group()[1]/@id"/>
               <xsl:attribute name="type" select="current-group()[1]/@type"/>
               <xsl:if test="exists(current-group()/@subtype)">
                  <xsl:attribute name="subtype">
                     <xsl:variable name="temp">
                        <xsl:perform-sort select="string-join(distinct-values(current-group()/@subtype[. ne '']), '-')">
                           <xsl:sort select="."/>
                        </xsl:perform-sort>
                     </xsl:variable>
                     <xsl:value-of select="string-join($temp, '/')"/>
                  </xsl:attribute>
               </xsl:if>
               <xsl:if test="current-group()[1]/@label">
                  <xsl:attribute name="label" select="current-group()[1]/@label"/>
               </xsl:if>
               <xsl:if test="current-group()[1]/@c">
                  <xsl:attribute name="c" select="sum(current-group()/@c)"/>
               </xsl:if>
               <xsl:for-each-group select="current-group()/*:controlfield"
                                    group-by="string-join((@tag, @type, string(.)), '')">
                  <xsl:sort select="@tag"/>
                  <xsl:element name="{name(current-group()[1])}"
                                namespace="{namespace-uri(current-group()[1])}">
                     <xsl:copy-of select="@* except @c"/>
                     <xsl:if test="current-group()[1]/@c">
                        <xsl:attribute name="c" select="sum(current-group()/@c)"/>
                     </xsl:if>
                     <xsl:value-of select="current-group()[1]"/>
                     <xsl:for-each-group select="current-group()/*:mid" group-by="@i">
                        <xsl:for-each select="distinct-values(current-group()/@i)">
                           <frbrizer:mid>
                              <xsl:attribute name="i" select="."/>
                           </frbrizer:mid>
                        </xsl:for-each>
                     </xsl:for-each-group>
                  </xsl:element>
               </xsl:for-each-group>
               <xsl:for-each-group select="current-group()/*:datafield"
                                    group-by="normalize-space(string-join(((@tag), @type,                             (if ($ignore_indicators_in_merge) then                                 ()                             else                                 (@ind1, @ind2)), *:subfield/@code, *:subfield/@type, *:subfield/text()), ''))">
                  <xsl:sort select="@tag"/>
                  <xsl:element name="{name(current-group()[1])}"
                                namespace="{namespace-uri(current-group()[1])}">
                     <xsl:copy-of select="current-group()[1]/@tag"/>
                     <xsl:copy-of select="current-group()[1]/@ind1"/>
                     <xsl:copy-of select="current-group()[1]/@ind2"/>
                     <xsl:copy-of select="current-group()[1]/@type"/>
                     <xsl:copy-of select="current-group()[1]/@subtype"/>
                     <xsl:copy-of select="current-group()[1]/@label"/>
                     <xsl:if test="current-group()[1]/@c">
                        <xsl:attribute name="c" select="sum(current-group()/@c)"/>
                     </xsl:if>
                     <xsl:for-each-group select="current-group()/*:subfield"
                                          group-by="concat(@code, @type, text())">
                        <xsl:sort select="@code"/>
                        <xsl:sort select="@type"/>
                        <xsl:for-each select="distinct-values(current-group()/text())">
                           <xsl:element name="{name(current-group()[1])}"
                                         namespace="{namespace-uri(current-group()[1])}">
                              <xsl:copy-of select="current-group()[1]/@code"/>
                              <xsl:copy-of select="current-group()[1]/@type"/>
                              <xsl:copy-of select="current-group()[1]/@subtype"/>
                              <xsl:if test="current-group()[1]/@label">
                                 <xsl:copy-of select="current-group()[1]/@label"/>
                              </xsl:if>
                              <xsl:value-of select="normalize-space(.)"/>
                           </xsl:element>
                        </xsl:for-each>
                     </xsl:for-each-group>
                     <xsl:for-each-group select="current-group()/*:mid" group-by="@i">
                        <xsl:for-each select="distinct-values(current-group()/@i)">
                           <xsl:element name="{name(current-group()[1])}"
                                         namespace="{namespace-uri(current-group()[1])}">
                              <xsl:attribute name="i" select="."/>
                           </xsl:element>
                        </xsl:for-each>
                     </xsl:for-each-group>
                  </xsl:element>
               </xsl:for-each-group>
               <xsl:for-each-group select="current-group()/*:relationship"
                                    group-by="concat(@type, @href, @subtype)">
                  <xsl:sort select="@type"/>
                  <xsl:sort select="@subtype"/>
                  <xsl:sort select="@id"/>
                  <xsl:element name="{name(current-group()[1])}"
                                namespace="{namespace-uri(current-group()[1])}">
                     <xsl:copy-of select="@* except (@c | @ilabel | @itype | @isubtype)"/>
                     <xsl:if test="current-group()[1]/@c">
                        <xsl:attribute name="c" select="sum(current-group()/@c)"/>
                     </xsl:if>
                     <xsl:for-each-group select="current-group()/*:mid" group-by="@i">
                        <xsl:for-each select="distinct-values(current-group()/@i)">
                           <xsl:element name="{name(current-group()[1])}"
                                         namespace="{namespace-uri(current-group()[1])}">
                              <xsl:attribute name="i" select="."/>
                           </xsl:element>
                        </xsl:for-each>
                     </xsl:for-each-group>
                  </xsl:element>
               </xsl:for-each-group>
               <xsl:for-each-group select="current-group()/*:template" group-by=".">
                  <xsl:element name="{name(current-group()[1])}"
                                namespace="{namespace-uri(current-group()[1])}">
                     <xsl:if test="current-group()[1]/@c">
                        <xsl:attribute name="c" select="sum(current-group()/@c)"/>
                     </xsl:if>
                     <xsl:value-of select="current-group()[1]"/>
                  </xsl:element>
               </xsl:for-each-group>
               <xsl:for-each-group select="current-group()/mid" group-by="@i">
                  <xsl:for-each select="distinct-values(current-group()/@i)">
                     <xsl:element name="{name(current-group()[1])}"
                                   namespace="{namespace-uri(current-group()[1])}">
                        <xsl:attribute name="i" select="."/>
                     </xsl:element>
                  </xsl:for-each>
               </xsl:for-each-group>
               <xsl:for-each-group select="current-group()/*:anchorvalue" group-by=".">
                  <xsl:element name="{name(current-group()[1])}"
                                namespace="{namespace-uri(current-group()[1])}">
                     <xsl:if test="current-group()[1]/@c">
                        <xsl:attribute name="c" select="sum(current-group()/@c)"/>
                     </xsl:if>
                     <xsl:value-of select="current-group()[1]"/>
                  </xsl:element>
               </xsl:for-each-group>
               <xsl:for-each-group select="current-group()/*:idvalue" group-by="@id">
                  <xsl:element name="{name(current-group()[1])}"
                                namespace="{namespace-uri(current-group()[1])}">
                     <xsl:if test="current-group()[1]/@c">
                        <xsl:attribute name="c" select="sum(current-group()/@c)"/>
                     </xsl:if>
                     <xsl:if test="current-group()[1]/@id">
                        <xsl:copy-of select="current-group()/@id"/>
                     </xsl:if>
                     <xsl:value-of select="current-group()[1]"/>
                  </xsl:element>
               </xsl:for-each-group>
               <xsl:for-each-group select="current-group()/*:source" group-by=".">
                  <xsl:element name="{name(current-group()[1])}"
                                namespace="{namespace-uri(current-group()[1])}">
                     <xsl:if test="current-group()[1]/@c">
                        <xsl:attribute name="c" select="sum(current-group()/@c)"/>
                     </xsl:if>
                     <xsl:value-of select="current-group()[1]"/>
                  </xsl:element>
               </xsl:for-each-group>
               <xsl:for-each-group select="current-group()/*:keyvalue" group-by=".">
                  <xsl:element name="{name(current-group()[1])}"
                                namespace="{namespace-uri(current-group()[1])}">
                     <xsl:if test="current-group()[1]/@c">
                        <xsl:attribute name="c" select="sum(current-group()/@c)"/>
                     </xsl:if>
                     <xsl:value-of select="current-group()[1]"/>
                  </xsl:element>
               </xsl:for-each-group>
               <xsl:for-each-group select="current-group()/*:label" group-by=".">
                  <xsl:element name="{name(current-group()[1])}"
                                namespace="{namespace-uri(current-group()[1])}">
                     <xsl:if test="current-group()[1]/@c">
                        <xsl:attribute name="c" select="sum(current-group()/@c)"/>
                     </xsl:if>
                     <xsl:value-of select="normalize-space(current-group()[1])"/>
                  </xsl:element>
               </xsl:for-each-group>
               <xsl:for-each-group select="current-group()/*:intkey" group-by=".">
                  <xsl:element name="intkey">
                     <xsl:if test="current-group()[1]/@c">
                        <xsl:attribute name="c" select="sum(current-group()/@c)"/>
                     </xsl:if>
                     <xsl:value-of select="current-group()[1]"/>
                  </xsl:element>
               </xsl:for-each-group>
            </xsl:element>
         </xsl:for-each-group>
      </xsl:copy>
   </xsl:template>
   <xsl:template xmlns:map="http://www.w3.org/2005/xpath-functions/map"
                  xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
                  xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
                  match="/*:collection"
                  mode="rdfify"
                  name="rdfify">
      <xsl:variable name="collection" select="."/>
      <rdf:RDF>
         <xsl:for-each select="in-scope-prefixes($collection)">
            <xsl:variable name="prefix" select="."/>
            <xsl:variable name="uri" select="namespace-uri-for-prefix(., $collection)"/>
            <xsl:if test="$prefix ne '' and not(starts-with($prefix, 'xs'))">
               <xsl:namespace name="{$prefix}" select="$uri"/>
            </xsl:if>
         </xsl:for-each>
         <xsl:variable name="prefixmap"
                        select="map:merge(for $i in in-scope-prefixes($collection) return map{namespace-uri-for-prefix($i, $collection) : $i})"/>
         <xsl:for-each-group select="//*:record[starts-with(@type, 'http')]"
                              group-by="@id, @type"
                              composite="yes">
                <!--<xsl:sort select="@type"/>
                <xsl:sort select="@id"/>-->
                <!--<xsl:variable name="namespace" select="tokenize(@type, '[/#]')[last() - 1]"/>-->
            <xsl:variable name="entity_type" select="tokenize(@type, '[/#]')[last()]"/>
            <xsl:variable name="entity_namespace" select="replace(@type, $entity_type, '')"/>
            <xsl:try>
               <xsl:element name="{$prefixmap($entity_namespace) || ':' || $entity_type}"
                             namespace="{$entity_namespace}">
                  <xsl:attribute name="rdf:about"
                                  select="if (starts-with(@id, 'http')) then @id else 'http://example.org/'||@id"/>
                  <xsl:for-each-group select="current-group()//(*:subfield, *:controlfield)[starts-with(@type, 'http')]"
                                       group-by="@type, replace(lower-case(text()), '[^A-Za-z0-9]', '')"
                                       composite="yes">
                     <xsl:variable name="property_type" select="tokenize(@type, '[/#]')[last()]"/>
                     <xsl:variable name="property_namespace" select="replace(@type, $property_type, '')"/>
                     <xsl:element name="{$prefixmap($property_namespace) || ':' || $property_type}"
                                   namespace="{$property_namespace}">
                        <xsl:copy-of select="current-group()[1]/text()"/>
                     </xsl:element>
                  </xsl:for-each-group>
                  <xsl:for-each-group select="current-group()/*:relationship[starts-with(@type, 'http')]"
                                       group-by="@type, @href"
                                       composite="yes">
                     <xsl:sort select="@type"/>
                     <xsl:variable name="property_type" select="tokenize(@type, '[/#]')[last()]"/>
                     <xsl:variable name="property_namespace" select="replace(@type, $property_type, '')"/>
                     <xsl:element name="{$prefixmap($property_namespace) || ':' || $property_type}"
                                   namespace="{$property_namespace}">
                        <xsl:attribute name="rdf:resource"
                                        select="if(starts-with(current-group()[1]/@href, 'http')) then current-group()[1]/@href else 'http://example.org/'||current-group()[1]/@href"/>
                     </xsl:element>
                  </xsl:for-each-group>
               </xsl:element>
               <xsl:catch xmlns:err="http://www.w3.org/2005/xqt-errors">
                  <xsl:message terminate="no">
                     <xsl:value-of select="'Error converting to rdf in record:'"/>
                     <xsl:copy-of select="."/>
                     <!--<xsl:value-of select="$entity_type"></xsl:value-of>-->
                     <!--<xsl:value-of select="$err:description"></xsl:value-of>-->
                  </xsl:message>
               </xsl:catch>
            </xsl:try>
         </xsl:for-each-group>
         <!--<xsl:for-each select="doc('rda.inverse.rdf')/rdf:RDF/rdf:Description">
                <xsl:copy-of select="."></xsl:copy-of>
            </xsl:for-each>-->
         <!--<xsl:for-each select="doc('rda.labels.rdf')/rdf:RDF/rdf:Description">
                <xsl:copy-of select="."></xsl:copy-of>
            </xsl:for-each>-->
      </rdf:RDF>
   </xsl:template>
   <xsl:function xmlns:local="http://idi.ntnu.no/frbrizer/"
                  xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
                  xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
                  name="local:sort-keys">
      <xsl:param name="keys"/>
      <xsl:perform-sort select="distinct-values($keys)">
         <xsl:sort select="."/>
      </xsl:perform-sort>
   </xsl:function>
   <xsl:function xmlns:local="http://idi.ntnu.no/frbrizer/"
                  xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
                  xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
                  name="local:sort-relationships">
      <xsl:param name="relationships"/>
      <xsl:perform-sort select="$relationships">
         <xsl:sort select="@id"/>
      </xsl:perform-sort>
   </xsl:function>
   <xsl:function xmlns:local="http://idi.ntnu.no/frbrizer/"
                  xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
                  xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
                  name="local:trimsort-targets">
      <xsl:param name="relationships"/>
      <xsl:perform-sort select="for $r in distinct-values($relationships) return local:trim-target($r)">
         <xsl:sort select="."/>
      </xsl:perform-sort>
   </xsl:function>
   <xsl:function xmlns:local="http://idi.ntnu.no/frbrizer/"
                  xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
                  xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
                  name="local:trim-target">
        <!-- This function transforms a list of uris to a list of strings containing the last part of the uri-->
      <xsl:param name="value" as="xs:string"/>
      <xsl:value-of select="let $x := $value return if (matches($x, '\w+:(/?/?)[^\s]+')) then (tokenize(replace($x, '/$', ''), '/'))[last()] else $x"/>
   </xsl:function>
   <xsl:function xmlns:mads="http://www.loc.gov/mads/rdf/v1#"
                  xmlns:mmmm="http://www.loc.gov/MARC21/slim/"
                  xmlns:rdaad="http://rdaregistry.info/Elements/a/datatype/"
                  xmlns:rdaao="http://rdaregistry.info/Elements/a/object/"
                  xmlns:rdac="http://rdaregistry.info/Elements/c/"
                  xmlns:rdaco="http://rdaregistry.info/termList/RDAContentType/"
                  xmlns:rdact="http://rdaregistry.info/termList/RDACarrierType/"
                  xmlns:rdaed="http://rdaregistry.info/Elements/e/datatype/"
                  xmlns:rdaeo="http://rdaregistry.info/Elements/e/object/"
                  xmlns:rdamd="http://rdaregistry.info/Elements/m/datatype/"
                  xmlns:rdamo="http://rdaregistry.info/Elements/m/object/"
                  xmlns:rdamt="http://rdaregistry.info/termList/RDAMediaType/"
                  xmlns:rdat="http://rdaregistry.info/termList/"
                  xmlns:rdawd="http://rdaregistry.info/Elements/w/datatype/"
                  xmlns:rdawo="http://rdaregistry.info/Elements/w/object/"
                  xmlns:rdaxd="http://rdaregistry.info/Elements/x/datatype/"
                  xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
                  xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
                  xmlns:skos="http://www.w3.org/2004/02/skos/core#"
                  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
                  name="frbrizer:validateURI">
      <xsl:param name="uri"/>
      <xsl:param name="field"/>
      <xsl:choose>
         <xsl:when test="xs:anyURI($uri) and starts-with($uri, 'http')">
            <xsl:value-of select="$uri"/>
         </xsl:when>
         <xsl:otherwise>
            <xsl:message terminate="no">Emty or invalid URI '<xsl:value-of select="$uri"/>' in field <xsl:value-of select="$field"/>
            </xsl:message>
            <xsl:value-of select="$uri"/>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:function>
   <xsl:function xmlns:mads="http://www.loc.gov/mads/rdf/v1#"
                  xmlns:mmmm="http://www.loc.gov/MARC21/slim/"
                  xmlns:rdaad="http://rdaregistry.info/Elements/a/datatype/"
                  xmlns:rdaao="http://rdaregistry.info/Elements/a/object/"
                  xmlns:rdac="http://rdaregistry.info/Elements/c/"
                  xmlns:rdaco="http://rdaregistry.info/termList/RDAContentType/"
                  xmlns:rdact="http://rdaregistry.info/termList/RDACarrierType/"
                  xmlns:rdaed="http://rdaregistry.info/Elements/e/datatype/"
                  xmlns:rdaeo="http://rdaregistry.info/Elements/e/object/"
                  xmlns:rdamd="http://rdaregistry.info/Elements/m/datatype/"
                  xmlns:rdamo="http://rdaregistry.info/Elements/m/object/"
                  xmlns:rdamt="http://rdaregistry.info/termList/RDAMediaType/"
                  xmlns:rdat="http://rdaregistry.info/termList/"
                  xmlns:rdawd="http://rdaregistry.info/Elements/w/datatype/"
                  xmlns:rdawo="http://rdaregistry.info/Elements/w/object/"
                  xmlns:rdaxd="http://rdaregistry.info/Elements/x/datatype/"
                  xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
                  xmlns:skos="http://www.w3.org/2004/02/skos/core#"
                  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
                  name="frbrizer:linked"
                  as="xs:boolean">
            <!-- returns true if the two fields have the same marc 21 link ($8), or if there is no linking subfields in target or source -->
      <xsl:param name="source" as="element()" required="yes"/>
      <xsl:param name="target" as="element()" required="yes"/>
      <xsl:param name="strict" as="xs:boolean" required="yes"/>
      <xsl:choose>
         <xsl:when test="$strict">
                    <!-- returns true if the two fields have the same marc 21 link ($8), or if there is no linking subfields in either source nor target -->
            <xsl:sequence select="some $x in $source/*:subfield[@code = '8'] satisfies $x = $target/*:subfield[@code = '8']"/>
         </xsl:when>
         <xsl:otherwise>
                    <!-- returns true if the two fields have the same marc 21 link ($8), or if there is no linking subfields in target -->
            <xsl:sequence select="(some $x in $source/*:subfield[@code = '8'] satisfies $x = $target/*:subfield[@code = '8']) or not(exists($target/*:subfield[@code='8']))"/>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:function>
   <xsl:function xmlns:mads="http://www.loc.gov/mads/rdf/v1#"
                  xmlns:mmmm="http://www.loc.gov/MARC21/slim/"
                  xmlns:rdaad="http://rdaregistry.info/Elements/a/datatype/"
                  xmlns:rdaao="http://rdaregistry.info/Elements/a/object/"
                  xmlns:rdac="http://rdaregistry.info/Elements/c/"
                  xmlns:rdaco="http://rdaregistry.info/termList/RDAContentType/"
                  xmlns:rdact="http://rdaregistry.info/termList/RDACarrierType/"
                  xmlns:rdaed="http://rdaregistry.info/Elements/e/datatype/"
                  xmlns:rdaeo="http://rdaregistry.info/Elements/e/object/"
                  xmlns:rdamd="http://rdaregistry.info/Elements/m/datatype/"
                  xmlns:rdamo="http://rdaregistry.info/Elements/m/object/"
                  xmlns:rdamt="http://rdaregistry.info/termList/RDAMediaType/"
                  xmlns:rdat="http://rdaregistry.info/termList/"
                  xmlns:rdawd="http://rdaregistry.info/Elements/w/datatype/"
                  xmlns:rdawo="http://rdaregistry.info/Elements/w/object/"
                  xmlns:rdaxd="http://rdaregistry.info/Elements/x/datatype/"
                  xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
                  xmlns:skos="http://www.w3.org/2004/02/skos/core#"
                  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
                  name="frbrizer:trim"
                  as="xs:string*">
      <xsl:param name="value" as="element()*"/>
      <xsl:for-each select="$value">
         <xsl:value-of select="replace(., '[\s\.,/:=]+$', '')"/>
      </xsl:for-each>
   </xsl:function>
   <xsl:function xmlns:mads="http://www.loc.gov/mads/rdf/v1#"
                  xmlns:mmmm="http://www.loc.gov/MARC21/slim/"
                  xmlns:rdaad="http://rdaregistry.info/Elements/a/datatype/"
                  xmlns:rdaao="http://rdaregistry.info/Elements/a/object/"
                  xmlns:rdac="http://rdaregistry.info/Elements/c/"
                  xmlns:rdaco="http://rdaregistry.info/termList/RDAContentType/"
                  xmlns:rdact="http://rdaregistry.info/termList/RDACarrierType/"
                  xmlns:rdaed="http://rdaregistry.info/Elements/e/datatype/"
                  xmlns:rdaeo="http://rdaregistry.info/Elements/e/object/"
                  xmlns:rdamd="http://rdaregistry.info/Elements/m/datatype/"
                  xmlns:rdamo="http://rdaregistry.info/Elements/m/object/"
                  xmlns:rdamt="http://rdaregistry.info/termList/RDAMediaType/"
                  xmlns:rdat="http://rdaregistry.info/termList/"
                  xmlns:rdawd="http://rdaregistry.info/Elements/w/datatype/"
                  xmlns:rdawo="http://rdaregistry.info/Elements/w/object/"
                  xmlns:rdaxd="http://rdaregistry.info/Elements/x/datatype/"
                  xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
                  xmlns:skos="http://www.w3.org/2004/02/skos/core#"
                  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
                  name="frbrizer:extent"
                  as="xs:string">
      <xsl:param name="datafield" as="element()"/>
      <xsl:variable name="extent">
         <xsl:if test="$datafield/*:subfield[@code='a']">
            <xsl:value-of select="replace($datafield/*:subfield[@code='a'], '[\s;:]+$', '')"/>
         </xsl:if>
         <xsl:if test="$datafield/*:subfield[@code='b']">
            <xsl:value-of select="' : ' || replace($datafield/*:subfield[@code='b'], '[\s;:]+$', '')"/>
         </xsl:if>
         <!--<xsl:if test="$datafield/*:subfield[@code='c']">
                    <xsl:value-of select="' ; ' || replace($datafield/*:subfield[@code='c'], '[\s;:]+$', '')"/>
                </xsl:if>-->
         <xsl:for-each select="$datafield/*:subfield[@code='c']/replace(., '[\s\.;:]+$', '')">
            <xsl:value-of select="', ' || replace(string-join(., ' ; '), '[\s\.]+$', '')"/>
         </xsl:for-each>
      </xsl:variable>
      <xsl:value-of select="replace(string-join($extent, ''), '[ \.]+$', '') || '.'"/>
   </xsl:function>
   <xsl:function xmlns:mads="http://www.loc.gov/mads/rdf/v1#"
                  xmlns:mmmm="http://www.loc.gov/MARC21/slim/"
                  xmlns:rdaad="http://rdaregistry.info/Elements/a/datatype/"
                  xmlns:rdaao="http://rdaregistry.info/Elements/a/object/"
                  xmlns:rdac="http://rdaregistry.info/Elements/c/"
                  xmlns:rdaco="http://rdaregistry.info/termList/RDAContentType/"
                  xmlns:rdact="http://rdaregistry.info/termList/RDACarrierType/"
                  xmlns:rdaed="http://rdaregistry.info/Elements/e/datatype/"
                  xmlns:rdaeo="http://rdaregistry.info/Elements/e/object/"
                  xmlns:rdamd="http://rdaregistry.info/Elements/m/datatype/"
                  xmlns:rdamo="http://rdaregistry.info/Elements/m/object/"
                  xmlns:rdamt="http://rdaregistry.info/termList/RDAMediaType/"
                  xmlns:rdat="http://rdaregistry.info/termList/"
                  xmlns:rdawd="http://rdaregistry.info/Elements/w/datatype/"
                  xmlns:rdawo="http://rdaregistry.info/Elements/w/object/"
                  xmlns:rdaxd="http://rdaregistry.info/Elements/x/datatype/"
                  xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
                  xmlns:skos="http://www.w3.org/2004/02/skos/core#"
                  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
                  name="frbrizer:publication"
                  as="xs:string">
      <xsl:param name="datafield" as="element()"/>
      <xsl:variable name="formatted" as="xs:string*">
         <xsl:for-each-group select="$datafield/*:subfield"
                              group-starting-with="*:subfield[@code = 'a']">
            <xsl:variable name="part" as="xs:string*">
               <xsl:for-each select="current-group()[@code = 'a']">
                  <xsl:value-of select="replace(., '[\s,;:]+$', '')"/>
               </xsl:for-each>
               <xsl:for-each select="current-group()[@code = 'b']">
                  <xsl:value-of select="' : ' || replace(., '[\s,;:]+$', '')"/>
               </xsl:for-each>
               <xsl:for-each select="current-group()[@code = 'c']/replace(., '[\s\.]+$', '')">
                  <xsl:value-of select="', ' || replace(string-join(., ' ; '), '[\s\.]+$', '')"/>
               </xsl:for-each>
            </xsl:variable>
            <xsl:value-of select="string-join($part, '')"/>
         </xsl:for-each-group>
      </xsl:variable>
      <xsl:choose>
         <xsl:when test="matches($formatted[last()], '\.$')">
            <xsl:value-of select="string-join($formatted, ' ; ')"/>
         </xsl:when>
         <xsl:otherwise>
            <xsl:value-of select="string-join($formatted, ' ; ') || '.'"/>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:function>
   <xsl:function xmlns:mads="http://www.loc.gov/mads/rdf/v1#"
                  xmlns:mmmm="http://www.loc.gov/MARC21/slim/"
                  xmlns:rdaad="http://rdaregistry.info/Elements/a/datatype/"
                  xmlns:rdaao="http://rdaregistry.info/Elements/a/object/"
                  xmlns:rdac="http://rdaregistry.info/Elements/c/"
                  xmlns:rdaco="http://rdaregistry.info/termList/RDAContentType/"
                  xmlns:rdact="http://rdaregistry.info/termList/RDACarrierType/"
                  xmlns:rdaed="http://rdaregistry.info/Elements/e/datatype/"
                  xmlns:rdaeo="http://rdaregistry.info/Elements/e/object/"
                  xmlns:rdamd="http://rdaregistry.info/Elements/m/datatype/"
                  xmlns:rdamo="http://rdaregistry.info/Elements/m/object/"
                  xmlns:rdamt="http://rdaregistry.info/termList/RDAMediaType/"
                  xmlns:rdat="http://rdaregistry.info/termList/"
                  xmlns:rdawd="http://rdaregistry.info/Elements/w/datatype/"
                  xmlns:rdawo="http://rdaregistry.info/Elements/w/object/"
                  xmlns:rdaxd="http://rdaregistry.info/Elements/x/datatype/"
                  xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
                  xmlns:skos="http://www.w3.org/2004/02/skos/core#"
                  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
                  name="frbrizer:idprefix">
      <xsl:param name="value"/>
      <xsl:choose>
         <xsl:when test="$value = '0'">
            <xsl:value-of select="'ISRC'"/>
         </xsl:when>
         <xsl:when test="$value = '1'">
            <xsl:value-of select="'UPC'"/>
         </xsl:when>
         <xsl:when test="$value = '2'">
            <xsl:value-of select="'ISMN'"/>
         </xsl:when>
         <xsl:when test="$value = '3'">
            <xsl:value-of select="'IAN'"/>
         </xsl:when>
         <xsl:when test="$value = '4'">
            <xsl:value-of select="'SICI'"/>
         </xsl:when>
         <xsl:otherwise>
            <xsl:value-of select="'NN'"/>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:function>
</xsl:stylesheet>
