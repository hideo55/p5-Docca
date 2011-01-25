use inc::Module::Install;
name 'Docca';
all_from 'lib/Docca.pm';

requires 'Mouse';
requires 'Text::Xslate';
requires 'Text::MultiMarkdown';
requires 'Text::Xatena';
requires 'Pod::Simple';
requires 'Furl';
requires 'IPC::Run';
tests 't/*.t';
author_tests 'xt';

test_requires 'Test::More';
test_requires 'Test::Fatal';
test_requires 'Data::Section::Simple';
WriteAll;
