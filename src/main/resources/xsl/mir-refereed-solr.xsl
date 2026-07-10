<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
  version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:mods="http://www.loc.gov/mods/v3"
  exclude-result-prefixes="mods"
>
  <!-- haengt sich in die (aktive) XSLT-1.0-Kette solr-document ein -->
  <xsl:import href="xslImport:solr-document:mir-refereed-solr.xsl"/>
  <xsl:include href="mir-characteristics-refereed.xsl"/>

  <xsl:template match="mycoreobject[contains(@ID,'_mods_')]">
    <!-- erst alle Felder der darunterliegenden Stylesheets (mir-solr.xsl etc.) -->
    <xsl:apply-imports/>
    <!-- dann unsere refereed-Felder -->
    <xsl:apply-templates select="metadata/def.modsContainer/modsContainer/mods:mods" mode="refereed"/>
  </xsl:template>

  <xsl:template match="mods:mods" mode="refereed">
    <xsl:variable name="refereed">
      <xsl:call-template name="getCharacteristicsRefereed">
        <xsl:with-param name="mods" select="."/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="value" select="normalize-space($refereed)"/>

    <!-- interne Facette: immer (yes|no|n/a) -->
    <field name="mods.refereed"><xsl:value-of select="$value"/></field>

    <!-- oeffentliche Facette: nur yes|no (kein n/a nach aussen) -->
    <xsl:if test="$value='yes' or $value='no'">
      <field name="mods.refereed.public"><xsl:value-of select="$value"/></field>
    </xsl:if>
  </xsl:template>

</xsl:stylesheet>
