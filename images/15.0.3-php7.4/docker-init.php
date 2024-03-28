#!/usr/bin/env php
<?php
require_once '../htdocs/master.inc.php';
require_once DOL_DOCUMENT_ROOT.'/core/lib/admin.lib.php';

printf("Activating module User... ");
activateModule('modUser');
printf("OK\n");

if (!empty(getenv('DOLI_ENABLE_MODULES'))) {
  $dirMods = array_keys(dolGetModulesDirs())[0];

  $mods = explode(',', getenv('DOLI_ENABLE_MODULES'));
  foreach ($mods as $mod) {
    $modName = 'mod'.$mod;
    $modFile = $modName.'.class.php';
    if (file_exists($dirMods.$modFile) ) {
      printf("Activating module ".$mod." ...");
      activateModule('mod' . $mod);
      printf(" OK\n");
    }
    else {
      printf("Unable to find module : ".$modName."\n");
    }
  }
}
