<?xml version="1.0" encoding="UTF-8"?>
<!--
  Zeigt "refereed" in der Metadatenbox (div#mir-metadata) an, inkl. der von
  host/series geerbten Werte und - wie in OpenAgrar - einem Info-Popover,
  das die Kette Objekt -> host/series mit der ausschlaggebenden Ebene zeigt.

  Hintergrund: MIR 2025.06 selektiert in mir-metadata-box.xsl nur
  mods:extension[@displayLabel='characteristics'] und nur auf Objektebene.
  reposis_hsbi nutzt das OpenAgrar-Modell mods:extension[@type='characteristics'].
  Statt die komplette mir-metadata-box.xsl zu kopieren (so macht es
  reposis_openagrar), faengt dieses Stylesheet die fertige Ausgabe der
  modsmeta-Kette ab und haengt eine Zeile an table.mir-metadata an.

  Das Popover nutzt den MIR-Mechanismus aus js/mir/base.js:
  <a class="personPopover" id="X"/> + <div id="X-content" class="d-none"/>.
-->
<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:mods="http://www.loc.gov/mods/v3"
  xmlns:i18n="xalan://org.mycore.services.i18n.MCRTranslation"
  xmlns:mcrxsl="xalan://org.mycore.common.xml.MCRXMLFunctions"
  xmlns:exslt="http://exslt.org/common"
  exclude-result-prefixes="mods i18n mcrxsl exslt">

  <xsl:import href="xslImport:modsmeta:metadata/hsbi-metadata-refereed.xsl"/>
  <xsl:include href="../mir-characteristics-refereed.xsl"/>

  <xsl:variable name="hsbi.mods"
                select="/mycoreobject/metadata/def.modsContainer/modsContainer/mods:mods"/>

  <xsl:variable name="hsbi.refereed.rtf">
    <xsl:call-template name="getCharacteristicsRefereed">
      <xsl:with-param name="mods" select="$hsbi.mods"/>
    </xsl:call-template>
  </xsl:variable>
  <xsl:variable name="hsbi.refereed" select="exslt:node-set($hsbi.refereed.rtf)/refereed"/>

  <!-- Gaeste sehen nur yes|no, angemeldete Nutzer zusaetzlich n/a und das Popover -->
  <xsl:variable name="hsbi.refereed.show"
                select="$hsbi.refereed/@value='yes' or $hsbi.refereed/@value='no'
                        or not(mcrxsl:isCurrentUserGuestUser())"/>

  <xsl:template match="/">
    <xsl:choose>
      <xsl:when test="$hsbi.refereed.show">
        <xsl:variable name="html">
          <xsl:apply-imports/>
        </xsl:variable>
        <xsl:apply-templates select="exslt:node-set($html)/node()" mode="hsbi-refereed"/>
      </xsl:when>
      <xsl:otherwise>
        <!-- nichts anzuzeigen: Kette unveraendert durchreichen -->
        <xsl:apply-imports/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- Identitaet -->
  <xsl:template match="@*|node()" mode="hsbi-refereed">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()" mode="hsbi-refereed"/>
    </xsl:copy>
  </xsl:template>

  <!-- Zeile an die Metadatentabelle anhaengen -->
  <xsl:template match="div[@id='mir-metadata']/table[contains(concat(' ', @class, ' '), ' mir-metadata ')]"
                mode="hsbi-refereed">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()" mode="hsbi-refereed"/>
      <tr>
        <td valign="top" class="metaname">
          <xsl:value-of select="concat(i18n:translate('component.mods.metaData.dictionary.refereed'), ':')"/>
        </td>
        <td class="metavalue">
          <xsl:value-of select="i18n:translate(concat('component.mods.metaData.dictionary.refereed.', $hsbi.refereed/@value))"/>
          <xsl:if test="not(mcrxsl:isCurrentUserGuestUser())">
            <div class="d-none" id="hsbiRefereedPopover-content">
              <table class="table table-sm table-borderless mb-0">
                <thead>
                  <tr>
                    <th><xsl:value-of select="i18n:translate('component.mods.metaData.dictionary.title')"/></th>
                    <th><xsl:value-of select="i18n:translate('component.mods.metaData.dictionary.genre')"/></th>
                    <th><xsl:value-of select="i18n:translate('component.mods.metaData.dictionary.refereed')"/></th>
                  </tr>
                </thead>
                <tbody>
                  <!-- von aussen (host der hosts) nach innen (Objekt), wie in OpenAgrar -->
                  <xsl:call-template name="hsbi.refereed.level">
                    <xsl:with-param name="node"
                                    select="$hsbi.mods/mods:relatedItem[@type='host' or @type='series']
                                                      /mods:relatedItem[@type='host' or @type='series']
                                                      /mods:relatedItem[@type='host' or @type='series']"/>
                    <xsl:with-param name="level" select="'4'"/>
                  </xsl:call-template>
                  <xsl:call-template name="hsbi.refereed.level">
                    <xsl:with-param name="node"
                                    select="$hsbi.mods/mods:relatedItem[@type='host' or @type='series']
                                                      /mods:relatedItem[@type='host' or @type='series']"/>
                    <xsl:with-param name="level" select="'3'"/>
                  </xsl:call-template>
                  <xsl:call-template name="hsbi.refereed.level">
                    <xsl:with-param name="node"
                                    select="$hsbi.mods/mods:relatedItem[@type='host' or @type='series']"/>
                    <xsl:with-param name="level" select="'2'"/>
                  </xsl:call-template>
                  <xsl:call-template name="hsbi.refereed.level">
                    <xsl:with-param name="node" select="$hsbi.mods"/>
                    <xsl:with-param name="level" select="'1'"/>
                    <xsl:with-param name="always" select="true()"/>
                  </xsl:call-template>
                </tbody>
              </table>
            </div>
            <a id="hsbiRefereedPopover" class="personPopover ml-1"
               title="{i18n:translate('component.mods.metaData.dictionary.refereed')}">
              <span class="fa fa-info-circle"/>
            </a>
          </xsl:if>
        </td>
      </tr>
    </xsl:copy>
  </xsl:template>

  <!-- eine Zeile des Popovers; die ausschlaggebende Ebene wird fett gesetzt -->
  <xsl:template name="hsbi.refereed.level">
    <xsl:param name="node"/>
    <xsl:param name="level"/>
    <xsl:param name="always" select="false()"/>
    <xsl:variable name="title" select="$node/mods:titleInfo/mods:title"/>
    <xsl:variable name="genre"
                  select="substring-after($node/mods:genre[contains(@authorityURI,'classifications/mir_genres')]/@valueURI, '#')"/>
    <xsl:if test="$always or $title != '' or $genre != ''">
      <tr>
        <xsl:if test="$hsbi.refereed/@level = $level">
          <xsl:attribute name="class">font-weight-bold</xsl:attribute>
        </xsl:if>
        <td><xsl:value-of select="$title"/></td>
        <td>
          <xsl:if test="$genre != ''">
            <xsl:value-of select="mcrxsl:getDisplayName('mir_genres', $genre)"/>
          </xsl:if>
        </td>
        <td>
          <xsl:value-of select="$node/mods:extension[@type='characteristics']/chars/@refereed"/>
        </td>
      </tr>
    </xsl:if>
  </xsl:template>

</xsl:stylesheet>
