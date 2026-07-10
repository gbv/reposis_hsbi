<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
  version="3.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:mods="http://www.loc.gov/mods/v3"
  xmlns:mir="http://www.mycore.de/mir/refereed"
  exclude-result-prefixes="#all"
>
  <!-- haengt sich in die XSLT-3.0-Kette solr-document-3 ein (Saxon) -->
  <xsl:import href="xslImport:solr-document-3:mir-refereed-solr-3.xsl"/>

  <!--
    Mehrstufig wie in OpenAgrar, aber idiomatisch in XSLT 3.0:
    baue die Kette Objekt -> host/series -> ... auf und nimm den
    naechstliegenden expliziten yes|no. Kein exslt:node-set noetig.
  -->
  <xsl:function name="mir:refereed" as="xs:string">
    <xsl:param name="mods" as="element(mods:mods)"/>

    <!-- Ebenen von innen (Objekt) nach aussen (verschachtelte host/series) -->
    <xsl:variable name="levels" as="element()*">
      <xsl:sequence select="$mods"/>
      <xsl:sequence select="$mods/mods:relatedItem[@type=('host','series')]"/>
      <xsl:sequence select="$mods/mods:relatedItem[@type=('host','series')]
                                 /mods:relatedItem[@type=('host','series')]"/>
      <xsl:sequence select="$mods/mods:relatedItem[@type=('host','series')]
                                 /mods:relatedItem[@type=('host','series')]
                                 /mods:relatedItem[@type=('host','series')]"/>
    </xsl:variable>

    <!-- erster expliziter yes|no in Ebenen-Reihenfolge; sonst n/a -->
    <xsl:variable name="hit" as="xs:string?"
      select="(for $l in $levels
                 return $l/mods:extension[@displayLabel='characteristics']/chars/@refereed
                          [. = ('yes','no')]/string())[1]"/>

    <xsl:sequence select="($hit, 'n/a')[1]"/>
  </xsl:function>

  <xsl:template match="mycoreobject[contains(@ID,'_mods_')]">
    <xsl:apply-imports/>
    <xsl:apply-templates select="metadata/def.modsContainer/modsContainer/mods:mods" mode="refereed"/>
  </xsl:template>

  <xsl:template match="mods:mods" mode="refereed">
    <xsl:variable name="value" select="mir:refereed(.)"/>

    <!-- interne Facette: immer (yes|no|n/a) -->
    <field name="mods.refereed">
      <xsl:value-of select="$value"/>
    </field>

    <!-- oeffentliche Facette: nur yes|no -->
    <xsl:if test="$value = ('yes','no')">
      <field name="mods.refereed.public">
        <xsl:value-of select="$value"/>
      </field>
    </xsl:if>
  </xsl:template>

</xsl:stylesheet>
