<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:i18n="xalan://org.mycore.services.i18n.MCRTranslation"
                exclude-result-prefixes="i18n">

  <!--
    Benutzerdefinierte Facette "mods.dateIssuedOnline" (Timebar).

    Anmeldung in mycore.properties:
      MCR.URIResolver.xslIncludes.facets=%MCR.URIResolver.xslIncludes.facets%,oa-facet-dateIssuedOnline.xsl
      MIR.Response.Facet.Custom=%MIR.Response.Facet.Custom%,mods.dateIssuedOnline

    Hinweis: $WebApplicationBaseURL NICHT erneut als xsl:param deklarieren -
    der Parameter ist global bereits vorhanden; eine zweite Deklaration mit
    gleicher Import-Precedence waere ein XSLT-Fehler.
  -->
  <xsl:template match="facet[@name='mods.dateIssuedOnline']" mode="custom-facet">
    <!-- die komplette Solr-Antwort, falls Trefferzahlen o.ae. gebraucht werden -->
    <xsl:param name="response"/>

    <xsl:variable name="timebarField" select="'mods.dateIssued'"/>
    <div class="card oa-dateIssuedOnlineFacet">
      <div class="card-header" data-toggle="collapse-next">
        <h3 class="card-title">
          <xsl:value-of select="i18n:translate('mir.search_facet.date.dateIssued')"/>
        </h3>
      </div>
      <div class="card-body collapse show">
        <script src="{$WebApplicationBaseURL}js/timebar.js" type="text/javascript"></script>
        <div class="oa-dateIssuedOnlineTimebar"
             data-timebar="true"
             data-timebar-height="100"
             data-search-field="{$timebarField}"
             data-timebar-start="0001-01-01T00:00:00Z"
             data-timebar-end="NOW"
             data-timebar-gap="+1YEAR"
             data-timebar-mincount="1"
        >
        </div>
      </div>
    </div>
  </xsl:template>

</xsl:stylesheet>