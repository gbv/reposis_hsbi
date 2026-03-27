<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:i18n="xalan://org.mycore.services.i18n.MCRTranslation"
    xmlns:mcrver="xalan://org.mycore.common.MCRCoreVersion"
    xmlns:mcrxsl="xalan://org.mycore.common.xml.MCRXMLFunctions"
    exclude-result-prefixes="i18n mcrver mcrxsl">

  <xsl:import href="resource:xsl/layout/mir-common-layout.xsl" />

  <xsl:template name="mir.navigation">

    <div id="header_box" class="container">
      <div id="project_logo_box">
        <a
          href="https://www.hsbi.de/"
          target="_blank"
          title="Zur Homepage der HSBI">
          <img
            src="{$WebApplicationBaseURL}/images/hsbi_logo2.svg"
            class=""
            alt="" />
        </a>
      </div>
      <div id="options_nav_box" class="mir-prop-nav">
        <div class="project-box">
          <a
            href="{concat($WebApplicationBaseURL,substring($loaded_navigation_xml/@hrefStartingPage,2))}"
            target="_blank"
            title="Zur Startseite des Publikationsservers">
            <img
              src="{$WebApplicationBaseURL}/images/hsbi_forschungsport_logo2.svg"
              class="project-box__logo"
              alt="" />
            <div class="project-box__name">Publikationsserver</div>
          </a>
        </div>
        <nav class="navbar navbar-light navbar-expand-sm">
          <ul class="navbar-nav">
            <xsl:call-template name="mir.loginMenu" />
            <xsl:call-template name="mir.languageMenu" />
          </ul>
        </nav>
      </div>
    </div>

    <!-- Collect the nav links, forms, and other content for toggling -->
    <div class="mir-main-nav bg-white">
      <div class="container">
        <nav class="navbar navbar-expand-lg navbar-light bg-white">

          <div class="container-fluid">
            <button
              class="navbar-toggler"
              type="button"
              data-bs-toggle="collapse"
              data-bs-target="#mir-main-nav-collapse-box"
              aria-controls="mir-main-nav-collapse-box"
              aria-expanded="false"
              aria-label="Toggle navigation">
              <span class="navbar-toggler-icon"></span>
            </button>

            <div
              id="mir-main-nav-collapse-box"
              class="collapse navbar-collapse mir-main-nav__entries justify-content-between">

              <ul class="navbar-nav me-auto mt-2 mt-lg-0">
                <xsl:call-template name="mir.generate_single_menu_entry">
                  <xsl:with-param name="menuID" select="'main'"/>
                </xsl:call-template>
                <xsl:for-each select="$loaded_navigation_xml/menu">
                  <xsl:choose>
                    <!-- Ignore some menus, they are shown elsewhere in the layout -->
                    <xsl:when test="@id='main'"/>
                    <xsl:when test="@id='brand'"/>
                    <xsl:when test="@id='below'"/>
                    <xsl:when test="@id='user'"/>
                    <xsl:otherwise>
                      <xsl:apply-templates select="."/>
                    </xsl:otherwise>
                  </xsl:choose>
                </xsl:for-each>
                <xsl:call-template name="mir.basketMenu" />
              </ul>

            <form
              action="{$WebApplicationBaseURL}servlets/solr/find"
              class="searchfield_box d-flex"
              role="search">
              <!-- Check if 'initialCondQuery' exists and extract its value if it does -->
              <xsl:variable name="initialCondQuery" select="/response/lst[@name='responseHeader']/lst[@name='params']/str[@name='initialCondQuery']" />

              <input
                name="condQuery"
                placeholder="{i18n:translate('mir.navsearch.placeholder')}"
                class="form-control me-sm-2 search-query"
                id="searchInput"
                type="text"
                aria-label="Search" />

              <input type="hidden" id="initialCondQueryMirFlatmirLayout" name="initialCondQuery">
                <xsl:attribute name="value">
                  <xsl:choose>
                    <xsl:when test="$initialCondQuery">
                      <xsl:value-of select="$initialCondQuery"/>
                    </xsl:when>
                    <xsl:otherwise>
                      <xsl:value-of select="'*'"/>
                    </xsl:otherwise>
                  </xsl:choose>
                </xsl:attribute>
              </input>

              <xsl:choose>
                <xsl:when test="contains($isSearchAllowedForCurrentUser, 'true')">
                  <input name="owner" type="hidden" value="createdby:*" />
                </xsl:when>
                <xsl:when test="not(mcrxsl:isCurrentUserGuestUser())">
                  <input name="owner" type="hidden" value="createdby:{$CurrentUser}" />
                </xsl:when>
              </xsl:choose>

              <button type="submit" class="btn btn-primary my-2 my-sm-0">
                <i class="fas fa-search"></i>
              </button>
            </form>
            </div>
          </div>

        </nav>
      </div>
    </div>
  </xsl:template>

  <xsl:template name="mir.jumbotwo">
    <!-- show only on startpage -->
    <xsl:if test="//div/@class='jumbotwo'">
    </xsl:if>
  </xsl:template>

  <xsl:template name="mir.footer">
    <div class="container">
      <div class="row">
        <div class="col">
          <div class="project_logo_box--footer">
            <a
              href="https://www.hsbi.de/"
              class="logo"
              target="_blank"
              title="Zur Homepage der HSBI">
              <img
                src="{$WebApplicationBaseURL}/images/hsbi_logo2.svg"
                class=""
                alt="" />
            </a>
          </div>
        </div>
      </div>
      <div class="row">
        <div class="col">
          <ul class="internal_links">
            <xsl:apply-templates select="$loaded_navigation_xml/menu[@id='brand']/*" />
          </ul>
        </div>
      </div>
    </div>
  </xsl:template>

  <xsl:template name="mir.powered_by">
    <xsl:variable name="mcr_version" select="concat('MyCoRe ',mcrver:getCompleteVersion())" />
    <div id="powered_by">
      <a href="http://www.mycore.de">
        <img src="{$WebApplicationBaseURL}mir-layout/images/mycore_logo_small_invert.png" title="{$mcr_version}" alt="powered by MyCoRe" />
      </a>
    </div>
  </xsl:template>

</xsl:stylesheet>
