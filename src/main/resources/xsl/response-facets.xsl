<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:encoder="xalan://java.net.URLEncoder"
                xmlns:i18n="xalan://org.mycore.services.i18n.MCRTranslation"
                xmlns:mcrxsl="xalan://org.mycore.common.xml.MCRXMLFunctions"
                xmlns:xalan="http://xml.apache.org/xalan"
                xmlns:fn="http://www.w3.org/2005/xpath-functions"
                xmlns:str="http://exslt.org/strings"
                xmlns:exslt="http://exslt.org/common"
                exclude-result-prefixes="i18n mcrxsl encoder xalan fn str exslt">

  <xsl:param name="CurrentLang"/>
  <xsl:param name="RequestURL"/>
  <xsl:param name="CurrentUser"/>

  <!--
    Laedt zusaetzliche Facetten-Stylesheets, die per Property angemeldet sind:
      MCR.URIResolver.xslIncludes.facets=meine-facette.xsl,noch-eine.xsl
    Ist die Property nicht gesetzt, liefert der Resolver ein leeres Stylesheet.
  -->
  <xsl:include href="xslInclude:facets"/>

  <xsl:variable name="facetProperties" select="document(concat('property:','MIR.Response.Facet.*'))"/>

  <!--
    Sichtbarkeit einer Facette. Ausgewertet werden:
      .Enabled  'false' schaltet die Facette ab (default: an)
      .Roles    kommaseparierte Positivliste von Rollen (leer = alle)
      .User     kommaseparierte Positivliste von Benutzernamen (leer = alle)
    Die drei Bedingungen werden UND-verknuepft. Rueckgabe: 'true' | 'false'.
  -->
  <xsl:template name="isFacetVisible">
    <xsl:param name="facet_name"/>

    <xsl:variable name="enabledProperty">
      <xsl:value-of select="$facetProperties/properties/entry[@key=concat('MIR.Response.Facet.', $facet_name, '.Enabled')]"/>
    </xsl:variable>
    <xsl:variable name="isEnabled" select="$enabledProperty!='false'"/>

    <xsl:variable name="rolesProperty">
      <xsl:value-of select="$facetProperties/properties/entry[@key=concat('MIR.Response.Facet.', $facet_name, '.Roles')]"/>
    </xsl:variable>
    <xsl:variable name="hasRole" select="string-length($rolesProperty)=0 or count(str:tokenize($rolesProperty,',')[mcrxsl:isCurrentUserInRole(.)])!=0"/>

    <xsl:variable name="userProperty">
      <xsl:value-of select="$facetProperties/properties/entry[@key=concat('MIR.Response.Facet.', $facet_name, '.User')]"/>
    </xsl:variable>
    <xsl:variable name="hasUser" select="string-length($userProperty)=0 or count(str:tokenize($userProperty,',')[.=$CurrentUser])!=0"/>

    <xsl:value-of select="$isEnabled and $hasRole and $hasUser"/>
  </xsl:template>

  <xsl:template name="facets">
    <!-- festhalten, da im Custom-Loop der Kontext ein temporaerer Baum ist -->
    <xsl:variable name="response" select="/response"/>

    <xsl:for-each select="/response/lst[@name='facet_counts']/lst[@name='facet_fields']/*">
      <xsl:variable name="facet_name" select="self::node()/@name"/>

      <xsl:variable name="visible">
        <xsl:call-template name="isFacetVisible">
          <xsl:with-param name="facet_name" select="$facet_name"/>
        </xsl:call-template>
      </xsl:variable>

      <xsl:if test="$visible='true' and self::node()[@name=$facet_name]/int">

        <xsl:variable name="classIdProperty">
          <xsl:value-of select="$facetProperties/properties/entry[@key=concat('MIR.Response.Facet.', $facet_name, '.ClassId')]"/>
        </xsl:variable>
        <xsl:variable name="classId">
          <xsl:choose>
            <xsl:when test="$classIdProperty!=''">
              <xsl:value-of select="$classIdProperty"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="$facet_name"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:variable>

        <xsl:variable name="categoryClassValuesProperty">
          <xsl:value-of select="$facetProperties/properties/entry[@key=concat('MIR.Response.Facet.', $facet_name, '.CategoryClassValues')]"/>
        </xsl:variable>
        <xsl:variable name="categoryClassValues">
          <xsl:choose>
            <xsl:when test="$categoryClassValuesProperty!=''">
              <xsl:value-of select="$categoryClassValuesProperty"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="'false'"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:variable>

        <xsl:variable name="parameterValuesProperty">
          <xsl:value-of select="$facetProperties/properties/entry[@key=concat('MIR.Response.Facet.', $facet_name, '.ParameterValues')]"/>
        </xsl:variable>
        <xsl:variable name="parameterValues">
          <xsl:choose>
            <xsl:when test="$parameterValuesProperty!=''">
              <xsl:value-of select="$parameterValuesProperty"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="'false'"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:variable>

        <!-- name of facet -->
        <div class="card {$facet_name}">
          <div class="card-header" data-mcr-toggle="collapse-next">
            <h3 class="card-title">
              <xsl:choose>
                <xsl:when test="i18n:exists(concat('mir.response.facet.', $facet_name, '.title'))">
                  <xsl:value-of select="i18n:translate(concat('mir.response.facet.', $facet_name, '.title'))"/>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:variable name="classification" select="document(concat('notnull:classification:metadata:0:children:', $classId))"/>
                  <xsl:choose>
                    <xsl:when test="not($classification/null)">
                      <xsl:variable name="label" select="$classification/mycoreclass/label[@xml:lang=$CurrentLang]/@text"/>
                      <xsl:choose>
                        <xsl:when test="string-length($label) &gt; 0">
                          <xsl:value-of select="$label"/>
                        </xsl:when>
                        <xsl:otherwise>
                          <xsl:value-of select="$facet_name"/>
                        </xsl:otherwise>
                      </xsl:choose>
                    </xsl:when>
                    <xsl:otherwise>
                      <xsl:value-of select="$facet_name"/>
                    </xsl:otherwise>
                  </xsl:choose>
                </xsl:otherwise>
              </xsl:choose>
            </h3>
          </div>

          <!-- facet values -->
          <div class="card-body collapse show">
            <ul class="filter">
              <xsl:apply-templates select="/response/lst[@name='facet_counts']/lst[@name='facet_fields']">
                <xsl:with-param name="facet_name" select="$facet_name"/>
                <xsl:with-param name="classId" select="$classId"/>
                <xsl:with-param name="categoryClassValues" select="$categoryClassValues='true'"/>
                <xsl:with-param name="parameterValues" select="$parameterValues='true'"/>
              </xsl:apply-templates>
            </ul>
          </div>
        </div>
      </xsl:if>
    </xsl:for-each>

    <!--
      Benutzerdefinierte Facetten. Welche gerendert werden und in welcher
      Reihenfolge, steuert:
        MIR.Response.Facet.Custom=mods.dateIssuedOnline,weitere.facette
      Das Rendern uebernimmt ein per xslInclude:facets geladenes Stylesheet mit
        <xsl:template match="facet[@name='mods.dateIssuedOnline']" mode="custom-facet">
      .Enabled / .Roles / .User gelten hier genauso wie bei Solr-Facetten.
    -->
    <xsl:variable name="customProperty">
      <xsl:value-of select="$facetProperties/properties/entry[@key='MIR.Response.Facet.Custom']"/>
    </xsl:variable>

    <xsl:variable name="customFacets">
      <xsl:for-each select="str:tokenize($customProperty, ',')">
        <facet name="{normalize-space(.)}"/>
      </xsl:for-each>
    </xsl:variable>

    <xsl:for-each select="exslt:node-set($customFacets)/facet">
      <xsl:variable name="visible">
        <xsl:call-template name="isFacetVisible">
          <xsl:with-param name="facet_name" select="@name"/>
        </xsl:call-template>
      </xsl:variable>
      <xsl:if test="$visible='true'">
        <xsl:apply-templates select="." mode="custom-facet">
          <xsl:with-param name="response" select="$response"/>
        </xsl:apply-templates>
      </xsl:if>
    </xsl:for-each>
  </xsl:template>

  <!-- Fallback: angemeldete, aber (noch) nicht implementierte Facette -> nichts ausgeben -->
  <xsl:template match="facet" mode="custom-facet" priority="-1"/>

  <xsl:template match="/response/lst[@name='facet_counts']/lst[@name='facet_fields']">
    <xsl:param name="facet_name"/>
    <xsl:param name="classId" select="$facet_name"/>
    <xsl:param name="categoryClassValues" select="false()"/>
    <xsl:param name="parameterValues" select="false()"/>

    <xsl:for-each select="lst[@name=$facet_name]/int">
      <xsl:variable name="fqValue">
        <xsl:choose>
          <xsl:when test="$categoryClassValues = true()">
            <xsl:value-of
              select="concat('category.top',':',substring-before(@name,':'),'%5C:',substring-after(@name,':'))"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="concat($facet_name,':',@name)"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:variable>

      <xsl:variable name="fqResponseValue">
        <xsl:choose>
          <xsl:when test="$categoryClassValues = true()">
            <xsl:value-of
              select="concat('category.top',':',substring-before(@name,':'),'\:',substring-after(@name,':'))"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="concat($facet_name,':',@name)"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:variable>
      <xsl:variable name="fqFragment" select="concat('fq=',$fqValue)"/>
      <xsl:variable name="fqFragmentEncoded" select="concat('fq=',encoder:encode($fqResponseValue, 'UTF-8'))"/>
      <xsl:variable name="queryWithoutStart" select="mcrxsl:regexp($RequestURL, '(&amp;|%26)(start=)[0-9]*', '')"/>

      <xsl:variable name="queryURL">
        <xsl:choose>
          <xsl:when test="contains($queryWithoutStart, $fqFragment)">
            <xsl:choose>
              <xsl:when test="not(substring-after($queryWithoutStart, $fqFragment))">
                <!-- last parameter -->
                <xsl:value-of
                  select="substring($queryWithoutStart, 1, string-length($queryWithoutStart) - string-length($fqFragment) - 1)"/>
              </xsl:when>
              <xsl:otherwise>
                <xsl:value-of
                  select="concat(substring-before($queryWithoutStart, $fqFragment), substring-after($queryWithoutStart, concat($fqFragment,'&amp;')))"/>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:when>
          <xsl:when test="contains($queryWithoutStart, $fqFragmentEncoded)">
            <xsl:choose>
              <xsl:when test="not(substring-after($queryWithoutStart, $fqFragmentEncoded))">
                <!-- last parameter -->
                <xsl:value-of
                  select="substring($queryWithoutStart, 1, string-length($queryWithoutStart) - string-length($fqFragmentEncoded) - 1)"/>
              </xsl:when>
              <xsl:otherwise>
                <xsl:value-of
                  select="concat(substring-before($queryWithoutStart, $fqFragmentEncoded), substring-after($queryWithoutStart, concat($fqFragmentEncoded,'&amp;')))"/>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:when>
          <xsl:when test="not(contains($queryWithoutStart, '?'))">
            <xsl:value-of select="concat($queryWithoutStart, '?', $fqFragment)"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="concat($queryWithoutStart, '&amp;', $fqFragment)"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:variable>

      <li data-fq="{$fqResponseValue}">
        <div class="form-check" onclick="location.href='{$queryURL}';">
          <input type="checkbox" class="form-check-input">
            <xsl:if test="
              /response/lst[@name='responseHeader']/lst[@name='params']/str[@name='fq' and text() = $fqResponseValue] |
              /response/lst[@name='responseHeader']/lst[@name='params']/arr[@name='fq']/str[text() = $fqResponseValue]">
              <xsl:attribute name="checked">true</xsl:attribute>
            </xsl:if>
          </input>

          <label class="form-check-label form-label">
            <span class="title">
              <xsl:call-template name="label">
                <xsl:with-param name="parameterValues" select="$parameterValues"/>
                <xsl:with-param name="categoryClassValues" select="$categoryClassValues"/>
                <xsl:with-param name="classId" select="$classId"/>
                <xsl:with-param name="facet_name" select="$facet_name"/>
              </xsl:call-template>
            </span>
            <span class="hits">
              <xsl:value-of select="."/>
            </span>
          </label>
        </div>
      </li>
    </xsl:for-each>
  </xsl:template>

  <xsl:template name="label">
    <xsl:param name="parameterValues"/>
    <xsl:param name="categoryClassValues"/>
    <xsl:param name="classId"/>
    <xsl:param name="facet_name"/>
    <xsl:choose>
      <xsl:when test="$parameterValues">
        <xsl:variable name="encodedParameterValue">
          <xsl:call-template name="UrlGetParam">
            <xsl:with-param name="url" select="$RequestURL" />
            <xsl:with-param name="par" select="concat('facet.label.',@name)" />
          </xsl:call-template>
        </xsl:variable>
        <xsl:variable name="parameterValue" xmlns:decoder="xalan://java.net.URLDecoder" select="decoder:decode($encodedParameterValue, 'UTF-8')"/>
        <xsl:choose>
          <xsl:when test="string-length($parameterValue)!=0">
            <xsl:value-of select="$parameterValue"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:call-template name="label">
              <xsl:with-param name="parameterValues" select="false()"/>
              <xsl:with-param name="categoryClassValues" select="$categoryClassValues"/>
              <xsl:with-param name="classId" select="$classId"/>
              <xsl:with-param name="facet_name" select="$facet_name"/>
            </xsl:call-template>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:when
          test="$categoryClassValues = true() and mcrxsl:isCategoryID(substring-before(@name, ':'), substring-after(@name, ':'))">
        <xsl:value-of
            select="mcrxsl:getDisplayName(substring-before(@name, ':'), substring-after(@name, ':'))"/>
      </xsl:when>
      <xsl:when test="mcrxsl:isCategoryID($classId, @name)">
        <xsl:value-of select="mcrxsl:getDisplayName($classId, @name)"/>
      </xsl:when>
      <xsl:when test="i18n:exists(concat('mir.response.facet.' ,$facet_name, '.value.', @name))">
        <xsl:value-of select="i18n:translate(concat('mir.response.facet.' ,$facet_name, '.value.', @name))"
                      disable-output-escaping="yes"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="@name"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

</xsl:stylesheet>
