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
    Datenmodell wie in reposis_openagrar:
    mods:extension[@type='characteristics']/chars/@refereed

    Funktional identisch zu mir-characteristics-refereed.xsl (XSLT 1.0),
    inklusive Ebenen-Information: mir:refereed-info() liefert
      <refereed value="yes|no|n/a" level="1|2|3|4|0"/>
    mir:refereed() ist der bequeme String-Zugriff fuer die Solr-Felder.
  -->

  <!-- erster expliziter yes|no innerhalb EINER Ebene -->
  <xsl:function name="mir:at-level" as="xs:string?">
    <xsl:param name="nodes" as="element()*"/>
    <xsl:sequence select="($nodes/mods:extension[@type='characteristics']
                                 /chars/@refereed[. = ('yes','no')]/string())[1]"/>
  </xsl:function>

  <xsl:function name="mir:refereed-info" as="element(refereed)">
    <xsl:param name="mods" as="element(mods:mods)"/>

    <!-- Ebenen von innen (Objekt) nach aussen (verschachtelte host/series) -->
    <xsl:variable name="d1" as="element()*" select="$mods"/>
    <xsl:variable name="d2" as="element()*" select="$d1/mods:relatedItem[@type = ('host','series')]"/>
    <xsl:variable name="d3" as="element()*" select="$d2/mods:relatedItem[@type = ('host','series')]"/>
    <xsl:variable name="d4" as="element()*" select="$d3/mods:relatedItem[@type = ('host','series')]"/>

    <!-- genau vier Eintraege, damit die Position der Ebene entspricht -->
    <xsl:variable name="values" as="xs:string+" select="
      (mir:at-level($d1), '')[1],
      (mir:at-level($d2), '')[1],
      (mir:at-level($d3), '')[1],
      (mir:at-level($d4), '')[1]"/>

    <!-- naechstliegende Ebene mit explizitem Wert; 0 = keine -->
    <xsl:variable name="level" as="xs:integer"
      select="((for $i in 1 to 4 return $i[$values[$i] ne ''])[1], 0)[1]"/>

    <refereed value="{if ($level eq 0) then 'n/a' else $values[$level]}" level="{$level}"/>
  </xsl:function>

  <xsl:function name="mir:refereed" as="xs:string">
    <xsl:param name="mods" as="element(mods:mods)"/>
    <xsl:sequence select="mir:refereed-info($mods)/@value/string()"/>
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
