<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
  version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:mods="http://www.loc.gov/mods/v3"
  exclude-result-prefixes="mods"
>

  <!--
    Zentrales Template: entscheidet, welcher Zustand (yes|no|n/a) indexiert wird.
    Mehrstufig wie in OpenAgrar: zuerst das Objekt selbst, dann rekursiv die
    host/series-relatedItems (bis 4 Ebenen). Der naechstliegende explizite
    Wert (yes|no) gewinnt; wird keiner gefunden -> n/a.

    Unterschied zu OpenAgrar 2021: MIR 2025 speichert die Eigenschaft unter
    mods:extension[@displayLabel='characteristics']/chars/@refereed
    (2021 war es nur mods:extension/chars/@refereed).
  -->
  <xsl:template name="getCharacteristicsRefereed">
    <xsl:param name="mods"/>
    <xsl:choose>
      <xsl:when test="$mods/mods:extension[@type='characteristics']/chars/@refereed='yes'">yes</xsl:when>
      <xsl:when test="$mods/mods:extension[@type='characteristics']/chars/@refereed='no'">no</xsl:when>
      <xsl:otherwise>
        <xsl:choose>
          <xsl:when test="$mods/mods:relatedItem[@type='host' or @type='series']/mods:extension[@type='characteristics']/chars/@refereed='yes'">yes</xsl:when>
          <xsl:when test="$mods/mods:relatedItem[@type='host' or @type='series']/mods:extension[@type='characteristics']/chars/@refereed='no'">no</xsl:when>
          <xsl:otherwise>
            <xsl:choose>
              <xsl:when test="$mods/mods:relatedItem[@type='host' or @type='series']/mods:relatedItem[@type='host' or @type='series']/mods:extension[@type='characteristics']/chars/@refereed='yes'">yes</xsl:when>
              <xsl:when test="$mods/mods:relatedItem[@type='host' or @type='series']/mods:relatedItem[@type='host' or @type='series']/mods:extension[@type='characteristics']/chars/@refereed='no'">no</xsl:when>
              <xsl:otherwise>
                <xsl:choose>
                  <xsl:when test="$mods/mods:relatedItem[@type='host' or @type='series']/mods:relatedItem[@type='host' or @type='series']/mods:relatedItem[@type='host' or @type='series']/mods:extension[@type='characteristics']/chars/@refereed='yes'">yes</xsl:when>
                  <xsl:when test="$mods/mods:relatedItem[@type='host' or @type='series']/mods:relatedItem[@type='host' or @type='series']/mods:relatedItem[@type='host' or @type='series']/mods:extension[@type='characteristics']/chars/@refereed='no'">no</xsl:when>
                  <xsl:otherwise>n/a</xsl:otherwise>
                </xsl:choose>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

</xsl:stylesheet>
