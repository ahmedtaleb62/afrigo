-- Support phone and terms text were already dynamic (platform_settings),
-- but no app ever actually read them -- every app still used a
-- hardcoded --dart-define support number and hardcoded dialog text for
-- privacy/terms/about. Adds the two missing content keys, and seeds all
-- three text keys with the real copy that was hardcoded in the client
-- app's dialogs (terms_and_conditions_ar/privacy_policy_ar/about_ar were
-- all still empty) so wiring the apps to read from here isn't a
-- regression to blank screens -- admin can edit the copy from here on.
insert into public.platform_settings (key, value) values
  ('privacy_policy_ar', '"تُستخدم بياناتك (الاسم، رقم الهاتف، الموقع التقريبي، سجل الطلبات) فقط لتشغيل الخدمة (المطابقة مع مزوّدي الخدمة، حساب الأسعار، التواصل بخصوص الطلب)، ولا تُشارك مع أي جهة خارجية لأغراض تسويقية."'::jsonb),
  ('about_ar', '"Afrigo منصة جزائرية تجمع خدمات التكسي وتوصيل الطعام والطرود في تطبيق واحد، تربط الركاب والزبائن بسائقين ومطاعم ومندوبي توصيل موثّقين."'::jsonb)
on conflict (key) do nothing;

update public.platform_settings
set value = '"باستخدامك تطبيق Afrigo فإنك توافق على استخدام الخدمة بحسن نية، ودفع مستحقات الرحلات والطلبات المكتملة، وعلى أن التطبيق وسيط بين المستخدم ومقدّمي الخدمة (السائقين والمطاعم ومندوبي التوصيل) دون تحمّل مسؤولية مباشرة عن جودة تنفيذهم."'::jsonb
where key = 'terms_and_conditions_ar' and value = '""'::jsonb;
