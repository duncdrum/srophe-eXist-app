<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:t="http://www.tei-c.org/ns/1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs t" version="2.0">
    <xsl:import href="langattr.xsl"/>
    <xsl:param name="withbdidefault">yes</xsl:param>
    <xsl:param name="withtypedefault">yes</xsl:param>
   
    <!-- NOTE: better handling for errors? right now prints as message, should there be a check they can run over thier docs periodically? -->
    <xsl:template name="get-title">
        <xsl:variable name="title" select="//t:titleStmt/t:title[@level='a'][1]"/>
        <xsl:choose>
            <xsl:when test="not($title)">
                <xsl:message terminate="no">
                    Couldn't find analytic title!
                </xsl:message>
            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates select="//t:titleStmt/t:title[@level='a']" mode="std-title"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <xsl:template name="place-title-std">
        <xsl:param name="mode">preindexed</xsl:param>
        <xsl:param name="place" select="."/>
        <xsl:param name="withbdi" select="$withbdidefault"/>
        <xsl:param name="withtype" select="$withtypedefault"/>
        <xsl:param name="firstlang">en</xsl:param>
        <xsl:param name="secondlang">syr</xsl:param>
        <xsl:param name="withplaceholder">yes</xsl:param>
        <xsl:choose>
            <xsl:when test="$mode='preindexed'">
                <xsl:apply-templates select="$place/t:placeName[@type='title']" mode="std-title"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:choose>
                    <xsl:when test="$place/t:placeName[not(@type) and @xml:lang=$firstlang]">
                        <xsl:apply-templates select="$place/t:placeName[not(@type) and @xml:lang=$firstlang][1]" mode="std-title">
                            <xsl:with-param name="withbdi" select="$withbdi"/>
                            <xsl:with-param name="withtype" select="$withtype"/>
                        </xsl:apply-templates>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:call-template name="not-avail">
                            <xsl:with-param name="withbdi" select="$withbdi"/>
                        </xsl:call-template>
                    </xsl:otherwise>
                </xsl:choose>
                <xsl:text> — </xsl:text>
                <xsl:choose>
                    <xsl:when test="$place/t:placeName[not(@type) and @xml:lang=$secondlang]">
                        <xsl:apply-templates select="$place/t:placeName[not(@type) and @xml:lang=$secondlang][1]" mode="std-title">
                            <xsl:with-param name="withbdi" select="$withbdi"/>
                            <xsl:with-param name="withtype">no</xsl:with-param>
                        </xsl:apply-templates>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:call-template name="not-avail">
                            <xsl:with-param name="withbdi" select="$withbdi"/>
                        </xsl:call-template>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <xsl:template match="t:title[@level='a']" mode="std-title">
        <xsl:for-each select="node()">
            <bdi>
                <xsl:for-each select="ancestor-or-self::t:*[@xml:lang][1]">
                    <xsl:attribute name="dir">
                        <xsl:call-template name="getdirection"/>
                    </xsl:attribute>
                    <!-- NOTE: maybe build as function? -->
                    <xsl:call-template name="langattr"/>
                </xsl:for-each>
                <xsl:apply-templates select="." mode="text-normal"/>
            </bdi>
        </xsl:for-each>
    </xsl:template>
    <xsl:template name="not-avail">
        <xsl:param name="withbdi" select="$withbdidefault"/>
        <xsl:choose>
            <xsl:when test="$withbdi='yes'">
                <bdi dir="ltr">[ Syriac Not Available ]</bdi>
            </xsl:when>
            <xsl:otherwise>
                <xsl:text>[ Romanized Not Available ]</xsl:text>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <xsl:template name="getdirection">
        <xsl:choose>
            <xsl:when test="not(@xml:lang)">
                <xsl:text/>
            </xsl:when>
            <xsl:when test="@xml:lang='en'">ltr</xsl:when>
            <xsl:when test="@xml:lang='syr' or @xml:lang='ar'">rtl</xsl:when>
            <xsl:otherwise>
                <xsl:text/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
</xsl:stylesheet>