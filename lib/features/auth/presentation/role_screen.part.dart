part of '../../../app/komekci_app.dart';


class RoleScreen extends StatefulWidget {
  const RoleScreen({super.key});
  @override
  State<RoleScreen> createState() => _RoleScreenState();
}

class _RoleScreenState extends State<RoleScreen> {
  bool isMaster = false;
  @override
  Widget build(BuildContext context) {
    final tr = Tr(context.watch<LanguageProvider>().language);
    final tokens = context.appTokens;
    return Scaffold(
      backgroundColor: tokens.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(28, 24, 28, 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Spacer(flex: 2),
              const Text(
                'KÖMEKÇI',
                style: TextStyle(
                  fontSize: 39,
                  letterSpacing: 4,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(flex: 2),
              Text(
                tr.chooseRole,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 36),
              Row(
                children: [
                  Expanded(
                    child: RoleCard(
                      selected: isMaster,
                      imageAsset: 'assets/images/role_master.png',
                      title: tr.master,
                      text: tr.masterText,
                      onTap: () {
                        context.read<AuthProvider>().chooseRole(
                          UserRole.master,
                        );
                        setState(() => isMaster = true);
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: RoleCard(
                      selected: !isMaster,
                      imageAsset: 'assets/images/role_client.jpg',
                      title: tr.client,
                      text: tr.clientText,
                      onTap: () {
                        context.read<AuthProvider>().chooseRole(
                          UserRole.client,
                        );
                        setState(() => isMaster = false);
                      },
                    ),
                  ),
                ],
              ),
              const Spacer(flex: 3),
              RoleContinueButton(
                label: tr.continueText,
                onTap: () {
                  context.read<AuthProvider>().chooseRole(
                    isMaster ? UserRole.master : UserRole.client,
                  );
                  Navigator.push(
                    context,
                    pageRoute(
                      isMaster
                          ? const MasterPhoneScreen()
                          : const RoleOnboardingScreen(isMaster: false),
                    ),
                  );
                },
              ),
              const SizedBox(height: 9),
              TextButton(
                onPressed: () =>
                    Navigator.push(context, pageRoute(const LoginScreen())),
                child: Center(child: Text(tr.haveAccount)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
