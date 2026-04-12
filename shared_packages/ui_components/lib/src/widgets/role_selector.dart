import 'package:flutter/material.dart';

enum UserRole {
  patient('patient', 'Patient', Icons.person, 'Access healthcare services'),
  doctor('doctor', 'Doctor', Icons.medical_services, 'Provide medical consultations'),
  pharmacist('pharmacist', 'Pharmacist', Icons.local_pharmacy, 'Manage pharmacy services'),
  nurse('nurse', 'Nurse', Icons.health_and_safety, 'Provide nursing care'),
  ambulance('ambulance', 'Ambulance', Icons.local_hospital, 'Emergency medical transport'),
  bloodbank('bloodbank', 'Blood Bank', Icons.bloodtype, 'Blood donation services'),
  pathology('pathology', 'Pathology', Icons.biotech, 'Laboratory services'),
  admin('admin', 'Admin', Icons.admin_panel_settings, 'Platform administration');

  const UserRole(this.value, this.displayName, this.icon, this.description);

  final String value;
  final String displayName;
  final IconData icon;
  final String description;

  static UserRole fromString(String value) {
    return UserRole.values.firstWhere(
      (role) => role.value == value,
      orElse: () => UserRole.patient,
    );
  }
}

class RoleSelector extends StatelessWidget {
  final UserRole? selectedRole;
  final void Function(UserRole) onRoleSelected;
  final List<UserRole> availableRoles;
  final bool showDescription;
  final bool isGridView;

  const RoleSelector({
    super.key,
    this.selectedRole,
    required this.onRoleSelected,
    this.availableRoles = UserRole.values,
    this.showDescription = true,
    this.isGridView = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isGridView) {
      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 1.2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: availableRoles.length,
        itemBuilder: (context, index) {
          final role = availableRoles[index];
          return _buildRoleCard(context, role);
        },
      );
    }

    return Column(
      children: availableRoles.map((role) => _buildRoleListTile(context, role)).toList(),
    );
  }

  Widget _buildRoleCard(BuildContext context, UserRole role) {
    final isSelected = selectedRole == role;
    final theme = Theme.of(context);

    return Card(
      elevation: isSelected ? 4 : 1,
      color: isSelected ? theme.colorScheme.primaryContainer : null,
      child: InkWell(
        onTap: () => onRoleSelected(role),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                role.icon,
                size: 32,
                color: isSelected
                    ? theme.colorScheme.onPrimaryContainer
                    : theme.colorScheme.primary,
              ),
              const SizedBox(height: 8),
              Text(
                role.displayName,
                style: theme.textTheme.titleSmall?.copyWith(
                  color: isSelected
                      ? theme.colorScheme.onPrimaryContainer
                      : theme.colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              if (showDescription) ...[
                const SizedBox(height: 4),
                Text(
                  role.description,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: isSelected
                        ? theme.colorScheme.onPrimaryContainer
                        : theme.colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoleListTile(BuildContext context, UserRole role) {
    final isSelected = selectedRole == role;
    final theme = Theme.of(context);

    return Card(
      elevation: isSelected ? 2 : 0,
      color: isSelected ? theme.colorScheme.primaryContainer : null,
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(
          role.icon,
          color: isSelected
              ? theme.colorScheme.onPrimaryContainer
              : theme.colorScheme.primary,
        ),
        title: Text(
          role.displayName,
          style: TextStyle(
            color: isSelected
                ? theme.colorScheme.onPrimaryContainer
                : theme.colorScheme.onSurface,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
        subtitle: showDescription
            ? Text(
                role.description,
                style: TextStyle(
                  color: isSelected
                      ? theme.colorScheme.onPrimaryContainer
                      : theme.colorScheme.onSurfaceVariant,
                ),
              )
            : null,
        trailing: isSelected
            ? Icon(
                Icons.check_circle,
                color: theme.colorScheme.onPrimaryContainer,
              )
            : null,
        onTap: () => onRoleSelected(role),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}

class RoleDropdown extends StatelessWidget {
  final UserRole? selectedRole;
  final void Function(UserRole?) onChanged;
  final List<UserRole> availableRoles;
  final String? hint;
  final String? label;

  const RoleDropdown({
    super.key,
    this.selectedRole,
    required this.onChanged,
    this.availableRoles = UserRole.values,
    this.hint,
    this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
        ],
        DropdownButtonFormField<UserRole>(
          value: selectedRole,
          onChanged: onChanged,
          hint: Text(hint ?? 'Select your role'),
          decoration: const InputDecoration(
            prefixIcon: Icon(Icons.person_outline),
          ),
          items: availableRoles.map((role) {
            return DropdownMenuItem<UserRole>(
              value: role,
              child: Row(
                children: [
                  Icon(role.icon, size: 20),
                  const SizedBox(width: 12),
                  Text(role.displayName),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}