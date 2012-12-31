#!/usr/bin/perl

use strict;
use warnings;
use POFOMD::Schema;

use Text::Unaccent;

use Text::Unidecode;
use Text::CSV_XS;
use Text2URI;
use String::Numeric qw(is_float);

my $t = new Text2URI();

my $schema = POFOMD::Schema->connect( "dbi:Pg:host=localhost;dbname=pofomd",
    "postgres", "" );
my $rs         = $schema->resultset('Gasto');
my $rs_dataset = $schema->resultset('Dataset');

if ( scalar(@ARGV) != 2 ) {
    print "Use $0 [year] [dataset.csv]\n";
    exit;
}

my $year    = $ARGV[0];
my $ds_name = 'Estado do Rio Grande do Sul';

my $dataset = $rs_dataset->find_or_create(
    {
        nome => $ds_name,
        periodo =>
          $schema->resultset('Periodo')->find_or_create( { ano => $year } ),
        uri => $t->translate(join('-', 'estado-rio-grande-do-sul', $year))
    }
);

my (
$ANO_RECEBIMENTO,$BIMESTRE_RECEBIMENTO,
$CD_ORGAO,$NOME_ORGAO,
$CD_ORGAO_ORCAMENTARIO,$NOME_ORGAO_ORCAMENTARIO,
$CD_UNIDADE_ORCAMENTARIA,$NOME_UNIDADE_ORCAMENTARIA,
$TIPO_OPERACAO,$ANO_EMPENHO,
$ANO_OPERACAO,$DT_EMPENHO,
$DT_OPERACAO,$NR_EMPENHO,
$CD_FUNCAO,$DS_FUNCAO,
$CD_SUBFUNCAO,$DS_SUBFUNCAO,
$CD_PROGRAMA,$DS_PROGRAMA,
$CD_PROJETO,$NM_PROJETO,
$CD_ELEMENTO,$CD_RUBRICA,
$DS_RUBRICA,$CD_RECURSO,
$NM_RECURSO,$CD_CREDOR,
$NM_CREDOR,$CNPJ_CPF,
$CGC_TE,$HISTORICO,
$VL_EMPENHO,$NR_LIQUIDACAO,
$VL_LIQUIDACAO,$NR_PAGAMENTO,
$VL_PAGAMENTO

);

my $csv = Text::CSV_XS->new(
    {
        allow_loose_quotes => 1,
        binary             => 1,
        verbatim           => 0,
        auto_diag          => 1,
        escape_char        => undef
    }
);

my ($FOO1, $FOO2, $FOO3, $FOO4, $FOO5);
my ($FOO6, $FOO7, $FOO8, $FOO9, $FOO10);

my ($BAR1, $BAR2, $BAR3, $BAR4, $BAR5);
my ($BAR6, $BAR7, $BAR8, $BAR9, $BAR10);

my ($BAR11, $BAR12, $BAR13, $BAR14, $BAR15);
my ($BAR16, $BAR17, $BAR18, $BAR19, $BAR20);

my ($BAR21, $BAR22, $BAR23, $BAR24, $BAR25);
my ($BAR26, $BAR27, $BAR28, $BAR29, $BAR30);

$csv->bind_columns(
\$ANO_RECEBIMENTO,\$BIMESTRE_RECEBIMENTO,
\$CD_ORGAO,\$NOME_ORGAO,
\$CD_ORGAO_ORCAMENTARIO,\$NOME_ORGAO_ORCAMENTARIO,
\$CD_UNIDADE_ORCAMENTARIA,\$NOME_UNIDADE_ORCAMENTARIA,
\$TIPO_OPERACAO,\$ANO_EMPENHO,
\$ANO_OPERACAO,\$DT_EMPENHO,
\$DT_OPERACAO,\$NR_EMPENHO,
\$CD_FUNCAO,\$DS_FUNCAO,
\$CD_SUBFUNCAO,\$DS_SUBFUNCAO,
\$CD_PROGRAMA,\$DS_PROGRAMA,
\$CD_PROJETO,\$NM_PROJETO,
\$CD_ELEMENTO,\$CD_RUBRICA,
\$DS_RUBRICA,\$CD_RECURSO,
\$NM_RECURSO,\$CD_CREDOR,
\$NM_CREDOR,\$CNPJ_CPF,
\$CGC_TE,\$HISTORICO,
\$VL_EMPENHO,\$NR_LIQUIDACAO,
\$VL_LIQUIDACAO,\$NR_PAGAMENTO,
\$VL_PAGAMENTO,

\$FOO1,\$FOO2,\$FOO3,\$FOO4,\$FOO5,
\$FOO6,\$FOO7,\$FOO8,\$FOO9,\$FOO10,

\$BAR1,\$BAR2,\$BAR3,\$BAR4,\$BAR5,
\$BAR6,\$BAR7,\$BAR8,\$BAR9,\$BAR10,

\$BAR11,\$BAR12,\$BAR13,\$BAR14,\$BAR15,
\$BAR16,\$BAR17,\$BAR18,\$BAR19,\$BAR20,

\$BAR21,\$BAR22,\$BAR23,\$BAR24,\$BAR25,
\$BAR26,\$BAR27,\$BAR28,\$BAR29,\$BAR30

);

# <:encoding(iso-8859-1)

open my $fh, '<', $ARGV[1] or die 'error';

my $line = 0;
my $cache_inserting = {};
&load_from_database($_) for qw /Funcao Subfuncao Programa Acao Beneficiario Despesa Gestora Recurso/;

$rs->search({dataset_id => $dataset->id})->delete;

while ( my $row = $csv->getline($fh) ) {
    $line++;
    next if $line == 1 or !$VL_LIQUIDACAO or !is_float($VL_LIQUIDACAO);
    print "$line\n";
    $VL_EMPENHO               =~ s/\,/\./g;
    $VL_LIQUIDACAO		=~ s/\,/\./g;
    $VL_PAGAMENTO =~ s/\,/\./g;
 
    my $obj = $rs->create(
        {
            dataset_id => $dataset->id,

            &cache_or_create(funcao => 'Funcao',
                { codigo => $CD_FUNCAO, nome => &remover_acentos($DS_FUNCAO) }
            ),

            &cache_or_create(subfuncao => 'Subfuncao',
                { codigo => $CD_SUBFUNCAO, nome => &remover_acentos($DS_SUBFUNCAO) } 
            ),

            &cache_or_create(programa => 'Programa',
                {
                    codigo => $CD_PROGRAMA,
                    nome   => &remover_acentos($DS_PROGRAMA)
                }
            ),

            &cache_or_create(acao => 'Acao',
                {
                    codigo => $CD_PROJETO,
                    nome   => &remover_acentos($NM_PROJETO)
                }
            ),

            &cache_or_create(beneficiario => 'Beneficiario',
                {
                    codigo    => $CD_CREDOR,
                    nome      => &remover_acentos($NM_CREDOR),
                    documento => $CNPJ_CPF,
                    uri       => $t->translate( &remover_acentos($NM_CREDOR) )
                }
            ),

            &cache_or_create(despesa => 'Despesa',
                {
                    codigo => 'rs-nao-informado',
                    nome   => 'nao-informado'
                }
            ),

            &cache_or_create(gestora => 'Gestora',
                {
                    codigo => $CD_UNIDADE_ORCAMENTARIA,
                    nome   => &remover_acentos($NOME_UNIDADE_ORCAMENTARIA)
                }
            ),

            pagamento => $schema->resultset('Pagamento')->create(
                {
                    numero_processo => $NR_PAGAMENTO || 0,
                    numero_nota_empenho => &remover_acentos($NR_EMPENHO),
                    tipo_licitacao  => 'nao-informado',
                    valor_empenhado => is_float($VL_EMPENHO) ? $VL_EMPENHO : 0,
                    valor_liquidado => $VL_LIQUIDACAO,
                    valor_pago_anos_anteriores => 0,
                }
            ),

            &cache_or_create(recurso => 'Recurso',
                {
                    codigo => &remover_acentos($CD_RECURSO),
                    nome   => &remover_acentos($NM_RECURSO)
                }
            ),
            valor => $VL_LIQUIDACAO
        }
    );

}

print "done\n";
close $fh;



sub load_from_database {
    my ($campo) = @_;

    my $campo_lc = lc $campo;
    my $rs = $schema->resultset($campo);
    my $r;
    $cache_inserting->{$campo_lc}{$r->codigo} = $r->id while ($r = $rs->next);
}

sub cache_or_create {
    my ($campo, $set, $info) = @_;

    my $codigo = $info->{codigo};
    my $id;

    if (exists $cache_inserting->{$campo}{$codigo}){

        $id = $cache_inserting->{$campo}{$codigo};

    }else{
        my $obj = $schema->resultset($set)->find_or_create($info);

        $cache_inserting->{$campo}{$codigo} = $id = $obj->id;
    };

    return ($campo . '_id' => $id);
}

sub remover_acentos {
    my $var = shift;
    $var = unac_string('UTF-8', $var);
    return $var;
}

