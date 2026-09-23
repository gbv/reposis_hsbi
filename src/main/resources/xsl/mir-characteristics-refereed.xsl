<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
  version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:mods="http://www.loc.gov/mods/v3"
  exclude-result-prefixes="mods"
>

  <!--
    Zentrales Template: entscheidet, welcher Zustand (yes|no|n/a) gilt.
    Mehrstufig wie in OpenAgrar: zuerst das Objekt selbst, dann rekursiv die
    host/series-relatedItems (bis 4 Ebenen). Der naechstliegende explizite
    Wert (yes|no) gewinnt; wird keiner gefunden -> n/a.

    Rueckgabe wie in OpenAgrar ein Fragment
      <refereed value="yes|no|n/a" level="1|2|3|4|0"/>
    damit Aufrufer (Metadatenbox) anzeigen koennen, WOHER der Wert stammt.
    Auslesen per exslt:node-set($var)/refereed/@value bzw. /@level.

    Datenmodell wie in reposis_openagrar:
    mods:extension[@type='characteristics']/chars/@refereed
  -->
  <xsl:template name="getCharacteristicsRefereed">
    <xsl:param name="mods"/>
    <xsl:variable name="lvl1" select="$mods"/>
    <xsl:variable name="lvl2" select="$lvl1/mods:relatedItem[@type='host' or @type='series']"/>
    <xsl:variable name="lvl3" select="$lvl2/mods:relatedItem[@type='host' or @type='series']"/>
    <xsl:variable name="lvl4" select="$lvl3/mods:relatedItem[@type='host' or @type='series']"/>
    <xsl:choose>
      <xsl:when test="$lvl1/mods:extension[@type='characteristics']/chars/@refereed='yes'">
        <refereed value="yes" level="1"/>
      </xsl:when>
      <xsl:when test="$lvl1/mods:extension[@type='characteristics']/chars/@refereed='no'">
        <refereed value="no" level="1"/>
      </xsl:when>
      <xsl:when test="$lvl2/mods:extension[@type='characteristics']/chars/@refereed='yes'">
        <refereed value="yes" level="2"/>
      </xsl:when>
      <xsl:when test="$lvl2/mods:extension[@type='characteristics']/chars/@refereed='no'">
        <refereed value="no" level="2"/>
      </xsl:when>
      <xsl:when test="$lvl3/mods:extension[@type='characteristics']/chars/@refereed='yes'">
        <refereed value="yes" level="3"/>
      </xsl:when>
      <xsl:when test="$lvl3/mods:extension[@type='characteristics']/chars/@refereed='no'">
        <refereed value="no" level="3"/>
      </xsl:when>
      <xsl:when test="$lvl4/mods:extension[@type='characteristics']/chars/@refereed='yes'">
        <refereed value="yes" level="4"/>
      </xsl:when>
      <xsl:when test="$lvl4/mods:extension[@type='characteristics']/chars/@refereed='no'">
        <refereed value="no" level="4"/>
      </xsl:when>
      <xsl:otherwise>
        <refereed value="n/a" level="0"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

</xsl:stylesheet>
