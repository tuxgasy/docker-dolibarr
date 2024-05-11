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
    } else {
      printf("Unable to find module : ".$modName."\n");
    }
  }
}

if (!empty(getenv('DOLI_COMPANY_COUNTRYCODE'))) {
    require_once DOL_DOCUMENT_ROOT.'/core/lib/company.lib.php';
    require_once DOL_DOCUMENT_ROOT.'/core/class/ccountry.class.php';
    $countryCode = getenv('DOLI_COMPANY_COUNTRYCODE');
    $country = new Ccountry($db);
    $res = $country->fetch(0,$countryCode);
    if ($res > 0 ) {
        $s = $country->id.':'.$country->code.':'.$country->label;
        dolibarr_set_const($db, "MAIN_INFO_SOCIETE_COUNTRY", $s, 'chaine', 0, '', $conf->entity);
        printf('Configuring for country : '.$s."\n");
        activateModulesRequiredByCountry($country->code);
        $db->commit();
    }
    else {
            printf('Unable to find country '.$countryCode."\n");
    }
}

if (!empty(getenv('DOLI_COMPANY_NAME'))) {
    $compname = getenv('DOLI_COMPANY_NAME');
    dolibarr_set_const($db, "MAIN_INFO_SOCIETE_NOM", $compname, 'chaine', 0, '', $conf->entity);
    $db->commit();
}
